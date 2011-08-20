
#line 1 "unicorn_http.rl"
/**
 * Copyright (c) 2009 Eric Wong (all bugs are Eric's fault)
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 */
#include "ruby.h"
#include "ext_help.h"
#include <assert.h>
#include <string.h>
#include <sys/types.h>
#include "common_field_optimization.h"
#include "global_variables.h"
#include "c_util.h"

void init_unicorn_httpdate(void);

#define UH_FL_CHUNKED  0x1
#define UH_FL_HASBODY  0x2
#define UH_FL_INBODY   0x4
#define UH_FL_HASTRAILER 0x8
#define UH_FL_INTRAILER 0x10
#define UH_FL_INCHUNK  0x20
#define UH_FL_REQEOF 0x40
#define UH_FL_KAVERSION 0x80
#define UH_FL_HASHEADER 0x100
#define UH_FL_TO_CLEAR 0x200

/* all of these flags need to be set for keepalive to be supported */
#define UH_FL_KEEPALIVE (UH_FL_KAVERSION | UH_FL_REQEOF | UH_FL_HASHEADER)

/*
 * whether or not to trust X-Forwarded-Proto and X-Forwarded-SSL when
 * setting rack.url_scheme
 */
static VALUE trust_x_forward = Qtrue;

static unsigned long keepalive_requests = 100; /* same as nginx */

/*
 * Returns the maximum number of keepalive requests a client may make
 * before the parser refuses to continue.
 */
static VALUE ka_req(VALUE self)
{
  return ULONG2NUM(keepalive_requests);
}

/*
 * Sets the maximum number of keepalive requests a client may make.
 * A special value of +nil+ causes this to be the maximum value
 * possible (this is architecture-dependent).
 */
static VALUE set_ka_req(VALUE self, VALUE val)
{
  keepalive_requests = NIL_P(val) ? ULONG_MAX : NUM2ULONG(val);

  return ka_req(self);
}

/*
 * Sets whether or not the parser will trust X-Forwarded-Proto and
 * X-Forwarded-SSL headers and set "rack.url_scheme" to "https" accordingly.
 * Rainbows!/Zbatery installations facing untrusted clients directly
 * should set this to +false+
 */
static VALUE set_xftrust(VALUE self, VALUE val)
{
  if (Qtrue == val || Qfalse == val)
    trust_x_forward = val;
  else
    rb_raise(rb_eTypeError, "must be true or false");

  return val;
}

/*
 * returns whether or not the parser will trust X-Forwarded-Proto and
 * X-Forwarded-SSL headers and set "rack.url_scheme" to "https" accordingly
 */
static VALUE xftrust(VALUE self)
{
  return trust_x_forward;
}

static size_t MAX_HEADER_LEN = 1024 * (80 + 32); /* same as Mongrel */

/* this is only intended for use with Rainbows! */
static VALUE set_maxhdrlen(VALUE self, VALUE len)
{
  return SIZET2NUM(MAX_HEADER_LEN = NUM2SIZET(len));
}

/* keep this small for Rainbows! since every client has one */
struct http_parser {
  int cs; /* Ragel internal state */
  unsigned int flags;
  unsigned long nr_requests;
  size_t mark;
  size_t offset;
  union { /* these 2 fields don't nest */
    size_t field;
    size_t query;
  } start;
  union {
    size_t field_len; /* only used during header processing */
    size_t dest_offset; /* only used during body processing */
  } s;
  VALUE buf;
  VALUE env;
  VALUE cont; /* Qfalse: unset, Qnil: ignored header, T_STRING: append */
  union {
    off_t content;
    off_t chunk;
  } len;
};

static ID id_clear, id_set_backtrace;

static void finalize_header(struct http_parser *hp);

static void parser_raise(VALUE klass, const char *msg)
{
  VALUE exc = rb_exc_new2(klass, msg);
  VALUE bt = rb_ary_new();

	rb_funcall(exc, id_set_backtrace, 1, bt);
	rb_exc_raise(exc);
}

#define REMAINING (unsigned long)(pe - p)
#define LEN(AT, FPC) (FPC - buffer - hp->AT)
#define MARK(M,FPC) (hp->M = (FPC) - buffer)
#define PTR_TO(F) (buffer + hp->F)
#define STR_NEW(M,FPC) rb_str_new(PTR_TO(M), LEN(M, FPC))
#define STRIPPED_STR_NEW(M,FPC) stripped_str_new(PTR_TO(M), LEN(M, FPC))

#define HP_FL_TEST(hp,fl) ((hp)->flags & (UH_FL_##fl))
#define HP_FL_SET(hp,fl) ((hp)->flags |= (UH_FL_##fl))
#define HP_FL_UNSET(hp,fl) ((hp)->flags &= ~(UH_FL_##fl))
#define HP_FL_ALL(hp,fl) (HP_FL_TEST(hp, fl) == (UH_FL_##fl))

static int is_lws(char c)
{
  return (c == ' ' || c == '\t');
}

static VALUE stripped_str_new(const char *str, long len)
{
  long end;

  for (end = len - 1; end >= 0 && is_lws(str[end]); end--);

  return rb_str_new(str, end + 1);
}

/*
 * handles values of the "Connection:" header, keepalive is implied
 * for HTTP/1.1 but needs to be explicitly enabled with HTTP/1.0
 * Additionally, we require GET/HEAD requests to support keepalive.
 */
static void hp_keepalive_connection(struct http_parser *hp, VALUE val)
{
  if (STR_CSTR_CASE_EQ(val, "keep-alive")) {
    /* basically have HTTP/1.0 masquerade as HTTP/1.1+ */
    HP_FL_SET(hp, KAVERSION);
  } else if (STR_CSTR_CASE_EQ(val, "close")) {
    /*
     * it doesn't matter what HTTP version or request method we have,
     * if a client says "Connection: close", we disable keepalive
     */
    HP_FL_UNSET(hp, KAVERSION);
  } else {
    /*
     * client could've sent anything, ignore it for now.  Maybe
     * "HP_FL_UNSET(hp, KAVERSION);" just in case?
     * Raising an exception might be too mean...
     */
  }
}

static void
request_method(struct http_parser *hp, const char *ptr, size_t len)
{
  VALUE v = rb_str_new(ptr, len);

  rb_hash_aset(hp->env, g_request_method, v);
}

static void
http_version(struct http_parser *hp, const char *ptr, size_t len)
{
  VALUE v;

  HP_FL_SET(hp, HASHEADER);

  if (CONST_MEM_EQ("HTTP/1.1", ptr, len)) {
    /* HTTP/1.1 implies keepalive unless "Connection: close" is set */
    HP_FL_SET(hp, KAVERSION);
    v = g_http_11;
  } else if (CONST_MEM_EQ("HTTP/1.0", ptr, len)) {
    v = g_http_10;
  } else {
    v = rb_str_new(ptr, len);
  }
  rb_hash_aset(hp->env, g_server_protocol, v);
  rb_hash_aset(hp->env, g_http_version, v);
}

static inline void hp_invalid_if_trailer(struct http_parser *hp)
{
  if (HP_FL_TEST(hp, INTRAILER))
    parser_raise(eHttpParserError, "invalid Trailer");
}

static void write_cont_value(struct http_parser *hp,
                             char *buffer, const char *p)
{
  char *vptr;
  long end;
  long len = LEN(mark, p);
  long cont_len;

  if (hp->cont == Qfalse)
     parser_raise(eHttpParserError, "invalid continuation line");
  if (NIL_P(hp->cont))
     return; /* we're ignoring this header (probably Host:) */

  assert(TYPE(hp->cont) == T_STRING && "continuation line is not a string");
  assert(hp->mark > 0 && "impossible continuation line offset");

  if (len == 0)
    return;

  cont_len = RSTRING_LEN(hp->cont);
  if (cont_len > 0) {
    --hp->mark;
    len = LEN(mark, p);
  }
  vptr = PTR_TO(mark);

  /* normalize tab to space */
  if (cont_len > 0) {
    assert((' ' == *vptr || '\t' == *vptr) && "invalid leading white space");
    *vptr = ' ';
  }

  for (end = len - 1; end >= 0 && is_lws(vptr[end]); end--);
  rb_str_buf_cat(hp->cont, vptr, end + 1);
}

static void write_value(struct http_parser *hp,
                        const char *buffer, const char *p)
{
  VALUE f = find_common_field(PTR_TO(start.field), hp->s.field_len);
  VALUE v;
  VALUE e;

  VALIDATE_MAX_LENGTH(LEN(mark, p), FIELD_VALUE);
  v = LEN(mark, p) == 0 ? rb_str_buf_new(128) : STRIPPED_STR_NEW(mark, p);
  if (NIL_P(f)) {
    const char *field = PTR_TO(start.field);
    size_t flen = hp->s.field_len;

    VALIDATE_MAX_LENGTH(flen, FIELD_NAME);

    /*
     * ignore "Version" headers since they conflict with the HTTP_VERSION
     * rack env variable.
     */
    if (CONST_MEM_EQ("VERSION", field, flen)) {
      hp->cont = Qnil;
      return;
    }
    f = uncommon_field(field, flen);
  } else if (f == g_http_connection) {
    hp_keepalive_connection(hp, v);
  } else if (f == g_content_length) {
    hp->len.content = parse_length(RSTRING_PTR(v), RSTRING_LEN(v));
    if (hp->len.content < 0)
      parser_raise(eHttpParserError, "invalid Content-Length");
    if (hp->len.content != 0)
      HP_FL_SET(hp, HASBODY);
    hp_invalid_if_trailer(hp);
  } else if (f == g_http_transfer_encoding) {
    if (STR_CSTR_CASE_EQ(v, "chunked")) {
      HP_FL_SET(hp, CHUNKED);
      HP_FL_SET(hp, HASBODY);
    }
    hp_invalid_if_trailer(hp);
  } else if (f == g_http_trailer) {
    HP_FL_SET(hp, HASTRAILER);
    hp_invalid_if_trailer(hp);
  } else {
    assert(TYPE(f) == T_STRING && "memoized object is not a string");
    assert_frozen(f);
  }

  e = rb_hash_aref(hp->env, f);
  if (NIL_P(e)) {
    hp->cont = rb_hash_aset(hp->env, f, v);
  } else if (f == g_http_host) {
    /*
     * ignored, absolute URLs in REQUEST_URI take precedence over
     * the Host: header (ref: rfc 2616, section 5.2.1)
     */
     hp->cont = Qnil;
  } else {
    rb_str_buf_cat(e, ",", 1);
    hp->cont = rb_str_buf_append(e, v);
  }
}

/** Machine **/


#line 422 "unicorn_http.rl"


/** Data **/

#line 324 "unicorn_http.c"
static const int http_parser_start = 1;
static const int http_parser_first_final = 122;
static const int http_parser_error = 0;

static const int http_parser_en_ChunkedBody = 100;
static const int http_parser_en_ChunkedBody_chunk_chunk_end = 106;
static const int http_parser_en_Trailers = 114;
static const int http_parser_en_main = 1;


#line 426 "unicorn_http.rl"

static void http_parser_init(struct http_parser *hp)
{
  int cs = 0;
  hp->flags = 0;
  hp->mark = 0;
  hp->offset = 0;
  hp->start.field = 0;
  hp->s.field_len = 0;
  hp->len.content = 0;
  hp->cont = Qfalse; /* zero on MRI, should be optimized away by above */
  
#line 348 "unicorn_http.c"
	{
	cs = http_parser_start;
	}

#line 438 "unicorn_http.rl"
  hp->cs = cs;
}

/** exec **/
static void
http_parser_execute(struct http_parser *hp, char *buffer, size_t len)
{
  const char *p, *pe;
  int cs = hp->cs;
  size_t off = hp->offset;

  if (cs == http_parser_first_final)
    return;

  assert(off <= len && "offset past end of buffer");

  p = buffer+off;
  pe = buffer+len;

  assert((void *)(pe - p) == (void *)(len - off) &&
         "pointers aren't same distance");

  if (HP_FL_TEST(hp, INCHUNK)) {
    HP_FL_UNSET(hp, INCHUNK);
    goto skip_chunk_data_hack;
  }
  
#line 381 "unicorn_http.c"
	{
	if ( p == pe )
		goto _test_eof;
	switch ( cs )
	{
case 1:
	switch( (*p) ) {
		case 33: goto tr0;
		case 71: goto tr2;
		case 124: goto tr0;
		case 126: goto tr0;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr0;
		} else if ( (*p) >= 35 )
			goto tr0;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr0;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr0;
		} else
			goto tr0;
	} else
		goto tr0;
	goto st0;
st0:
cs = 0;
	goto _out;
tr0:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st2;
st2:
	if ( ++p == pe )
		goto _test_eof2;
case 2:
#line 423 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st49;
		case 124: goto st49;
		case 126: goto st49;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st49;
		} else if ( (*p) >= 35 )
			goto st49;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st49;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st49;
		} else
			goto st49;
	} else
		goto st49;
	goto st0;
tr3:
#line 327 "unicorn_http.rl"
	{ request_method(hp, PTR_TO(mark), LEN(mark, p)); }
	goto st3;
st3:
	if ( ++p == pe )
		goto _test_eof3;
case 3:
#line 456 "unicorn_http.c"
	switch( (*p) ) {
		case 42: goto tr5;
		case 47: goto tr6;
		case 72: goto tr7;
		case 104: goto tr7;
	}
	goto st0;
tr5:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st4;
st4:
	if ( ++p == pe )
		goto _test_eof4;
case 4:
#line 472 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr8;
		case 35: goto tr9;
	}
	goto st0;
tr8:
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st5;
tr37:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
#line 347 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), FRAGMENT);
    rb_hash_aset(hp->env, g_fragment, STR_NEW(mark, p));
  }
	goto st5;
tr40:
#line 347 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), FRAGMENT);
    rb_hash_aset(hp->env, g_fragment, STR_NEW(mark, p));
  }
	goto st5;
tr44:
#line 357 "unicorn_http.rl"
	{
    VALUE val;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_PATH);
    val = rb_hash_aset(hp->env, g_request_path, STR_NEW(mark, p));

    /* rack says PATH_INFO must start with "/" or be empty */
    if (!STR_CSTR_EQ(val, "*"))
      rb_hash_aset(hp->env, g_path_info, val);
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st5;
tr50:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st5;
tr54:
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st5;
st5:
	if ( ++p == pe )
		goto _test_eof5;
case 5:
#line 593 "unicorn_http.c"
	if ( (*p) == 72 )
		goto tr10;
	goto st0;
tr10:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st6;
st6:
	if ( ++p == pe )
		goto _test_eof6;
case 6:
#line 605 "unicorn_http.c"
	if ( (*p) == 84 )
		goto st7;
	goto st0;
st7:
	if ( ++p == pe )
		goto _test_eof7;
case 7:
	if ( (*p) == 84 )
		goto st8;
	goto st0;
st8:
	if ( ++p == pe )
		goto _test_eof8;
case 8:
	if ( (*p) == 80 )
		goto st9;
	goto st0;
st9:
	if ( ++p == pe )
		goto _test_eof9;
case 9:
	if ( (*p) == 47 )
		goto st10;
	goto st0;
st10:
	if ( ++p == pe )
		goto _test_eof10;
case 10:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st11;
	goto st0;
st11:
	if ( ++p == pe )
		goto _test_eof11;
case 11:
	if ( (*p) == 46 )
		goto st12;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st11;
	goto st0;
st12:
	if ( ++p == pe )
		goto _test_eof12;
case 12:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st13;
	goto st0;
st13:
	if ( ++p == pe )
		goto _test_eof13;
case 13:
	if ( (*p) == 13 )
		goto tr18;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st13;
	goto st0;
tr18:
#line 356 "unicorn_http.rl"
	{ http_version(hp, PTR_TO(mark), LEN(mark, p)); }
	goto st14;
tr25:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
#line 326 "unicorn_http.rl"
	{ write_cont_value(hp, buffer, p); }
	goto st14;
tr27:
#line 326 "unicorn_http.rl"
	{ write_cont_value(hp, buffer, p); }
	goto st14;
tr33:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
#line 325 "unicorn_http.rl"
	{ write_value(hp, buffer, p); }
	goto st14;
tr35:
#line 325 "unicorn_http.rl"
	{ write_value(hp, buffer, p); }
	goto st14;
st14:
	if ( ++p == pe )
		goto _test_eof14;
case 14:
#line 690 "unicorn_http.c"
	if ( (*p) == 10 )
		goto st15;
	goto st0;
st15:
	if ( ++p == pe )
		goto _test_eof15;
case 15:
	switch( (*p) ) {
		case 9: goto st16;
		case 13: goto st18;
		case 32: goto st16;
		case 33: goto tr22;
		case 124: goto tr22;
		case 126: goto tr22;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr22;
		} else if ( (*p) >= 35 )
			goto tr22;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr22;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr22;
		} else
			goto tr22;
	} else
		goto tr22;
	goto st0;
tr24:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st16;
st16:
	if ( ++p == pe )
		goto _test_eof16;
case 16:
#line 732 "unicorn_http.c"
	switch( (*p) ) {
		case 9: goto tr24;
		case 13: goto tr25;
		case 32: goto tr24;
	}
	goto tr23;
tr23:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st17;
st17:
	if ( ++p == pe )
		goto _test_eof17;
case 17:
#line 747 "unicorn_http.c"
	if ( (*p) == 13 )
		goto tr27;
	goto st17;
tr99:
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st18;
tr102:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
#line 347 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), FRAGMENT);
    rb_hash_aset(hp->env, g_fragment, STR_NEW(mark, p));
  }
	goto st18;
tr105:
#line 347 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), FRAGMENT);
    rb_hash_aset(hp->env, g_fragment, STR_NEW(mark, p));
  }
	goto st18;
tr109:
#line 357 "unicorn_http.rl"
	{
    VALUE val;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_PATH);
    val = rb_hash_aset(hp->env, g_request_path, STR_NEW(mark, p));

    /* rack says PATH_INFO must start with "/" or be empty */
    if (!STR_CSTR_EQ(val, "*"))
      rb_hash_aset(hp->env, g_path_info, val);
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st18;
tr115:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st18;
tr119:
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st18;
st18:
	if ( ++p == pe )
		goto _test_eof18;
case 18:
#line 866 "unicorn_http.c"
	if ( (*p) == 10 )
		goto tr28;
	goto st0;
tr28:
#line 372 "unicorn_http.rl"
	{
    finalize_header(hp);

    cs = http_parser_first_final;
    if (HP_FL_TEST(hp, HASBODY)) {
      HP_FL_SET(hp, INBODY);
      if (HP_FL_TEST(hp, CHUNKED))
        cs = http_parser_en_ChunkedBody;
    } else {
      HP_FL_SET(hp, REQEOF);
      assert(!HP_FL_TEST(hp, CHUNKED) && "chunked encoding without body!");
    }
    /*
     * go back to Ruby so we can call the Rack application, we'll reenter
     * the parser iff the body needs to be processed.
     */
    goto post_exec;
  }
	goto st122;
st122:
	if ( ++p == pe )
		goto _test_eof122;
case 122:
#line 895 "unicorn_http.c"
	goto st0;
tr22:
#line 320 "unicorn_http.rl"
	{ MARK(start.field, p); }
#line 321 "unicorn_http.rl"
	{ snake_upcase_char(deconst(p)); }
	goto st19;
tr29:
#line 321 "unicorn_http.rl"
	{ snake_upcase_char(deconst(p)); }
	goto st19;
st19:
	if ( ++p == pe )
		goto _test_eof19;
case 19:
#line 911 "unicorn_http.c"
	switch( (*p) ) {
		case 33: goto tr29;
		case 58: goto tr30;
		case 124: goto tr29;
		case 126: goto tr29;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr29;
		} else if ( (*p) >= 35 )
			goto tr29;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr29;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr29;
		} else
			goto tr29;
	} else
		goto tr29;
	goto st0;
tr32:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st20;
tr30:
#line 323 "unicorn_http.rl"
	{ hp->s.field_len = LEN(start.field, p); }
	goto st20;
st20:
	if ( ++p == pe )
		goto _test_eof20;
case 20:
#line 948 "unicorn_http.c"
	switch( (*p) ) {
		case 9: goto tr32;
		case 13: goto tr33;
		case 32: goto tr32;
	}
	goto tr31;
tr31:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st21;
st21:
	if ( ++p == pe )
		goto _test_eof21;
case 21:
#line 963 "unicorn_http.c"
	if ( (*p) == 13 )
		goto tr35;
	goto st21;
tr9:
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st22;
tr45:
#line 357 "unicorn_http.rl"
	{
    VALUE val;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_PATH);
    val = rb_hash_aset(hp->env, g_request_path, STR_NEW(mark, p));

    /* rack says PATH_INFO must start with "/" or be empty */
    if (!STR_CSTR_EQ(val, "*"))
      rb_hash_aset(hp->env, g_path_info, val);
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st22;
tr51:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st22;
tr55:
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st22;
st22:
	if ( ++p == pe )
		goto _test_eof22;
case 22:
#line 1066 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr37;
		case 35: goto st0;
		case 37: goto tr38;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto tr36;
tr36:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st23;
st23:
	if ( ++p == pe )
		goto _test_eof23;
case 23:
#line 1084 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr40;
		case 35: goto st0;
		case 37: goto st24;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st23;
tr38:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st24;
st24:
	if ( ++p == pe )
		goto _test_eof24;
case 24:
#line 1102 "unicorn_http.c"
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st25;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st25;
	} else
		goto st25;
	goto st0;
st25:
	if ( ++p == pe )
		goto _test_eof25;
case 25:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st23;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st23;
	} else
		goto st23;
	goto st0;
tr6:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st26;
tr71:
#line 331 "unicorn_http.rl"
	{ rb_hash_aset(hp->env, g_http_host, STR_NEW(mark, p)); }
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st26;
st26:
	if ( ++p == pe )
		goto _test_eof26;
case 26:
#line 1139 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr44;
		case 35: goto tr45;
		case 37: goto st27;
		case 63: goto tr47;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st26;
st27:
	if ( ++p == pe )
		goto _test_eof27;
case 27:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st28;
	} else
		goto st28;
	goto st0;
st28:
	if ( ++p == pe )
		goto _test_eof28;
case 28:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st26;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st26;
	} else
		goto st26;
	goto st0;
tr47:
#line 357 "unicorn_http.rl"
	{
    VALUE val;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_PATH);
    val = rb_hash_aset(hp->env, g_request_path, STR_NEW(mark, p));

    /* rack says PATH_INFO must start with "/" or be empty */
    if (!STR_CSTR_EQ(val, "*"))
      rb_hash_aset(hp->env, g_path_info, val);
  }
	goto st29;
st29:
	if ( ++p == pe )
		goto _test_eof29;
case 29:
#line 1193 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr50;
		case 35: goto tr51;
		case 37: goto tr52;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto tr49;
tr49:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
	goto st30;
st30:
	if ( ++p == pe )
		goto _test_eof30;
case 30:
#line 1211 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr54;
		case 35: goto tr55;
		case 37: goto st31;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st30;
tr52:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
	goto st31;
st31:
	if ( ++p == pe )
		goto _test_eof31;
case 31:
#line 1229 "unicorn_http.c"
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st32;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st32;
	} else
		goto st32;
	goto st0;
st32:
	if ( ++p == pe )
		goto _test_eof32;
case 32:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st30;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st30;
	} else
		goto st30;
	goto st0;
tr7:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st33;
st33:
	if ( ++p == pe )
		goto _test_eof33;
case 33:
#line 1262 "unicorn_http.c"
	switch( (*p) ) {
		case 84: goto tr58;
		case 116: goto tr58;
	}
	goto st0;
tr58:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st34;
st34:
	if ( ++p == pe )
		goto _test_eof34;
case 34:
#line 1276 "unicorn_http.c"
	switch( (*p) ) {
		case 84: goto tr59;
		case 116: goto tr59;
	}
	goto st0;
tr59:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st35;
st35:
	if ( ++p == pe )
		goto _test_eof35;
case 35:
#line 1290 "unicorn_http.c"
	switch( (*p) ) {
		case 80: goto tr60;
		case 112: goto tr60;
	}
	goto st0;
tr60:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st36;
st36:
	if ( ++p == pe )
		goto _test_eof36;
case 36:
#line 1304 "unicorn_http.c"
	switch( (*p) ) {
		case 58: goto tr61;
		case 83: goto tr62;
		case 115: goto tr62;
	}
	goto st0;
tr61:
#line 328 "unicorn_http.rl"
	{
    rb_hash_aset(hp->env, g_rack_url_scheme, STR_NEW(mark, p));
  }
	goto st37;
st37:
	if ( ++p == pe )
		goto _test_eof37;
case 37:
#line 1321 "unicorn_http.c"
	if ( (*p) == 47 )
		goto st38;
	goto st0;
st38:
	if ( ++p == pe )
		goto _test_eof38;
case 38:
	if ( (*p) == 47 )
		goto st39;
	goto st0;
st39:
	if ( ++p == pe )
		goto _test_eof39;
case 39:
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto st0;
		case 60: goto st0;
		case 91: goto tr68;
		case 95: goto tr67;
		case 127: goto st0;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 57 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 64 )
				goto st0;
		} else if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr67;
		} else
			goto tr67;
	} else
		goto tr67;
	goto st40;
st40:
	if ( ++p == pe )
		goto _test_eof40;
case 40:
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto st0;
		case 60: goto st0;
		case 64: goto st39;
		case 127: goto st0;
	}
	if ( (*p) < 34 ) {
		if ( 0 <= (*p) && (*p) <= 32 )
			goto st0;
	} else if ( (*p) > 35 ) {
		if ( 62 <= (*p) && (*p) <= 63 )
			goto st0;
	} else
		goto st0;
	goto st40;
st41:
	if ( ++p == pe )
		goto _test_eof41;
case 41:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st42;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st42;
	} else
		goto st42;
	goto st0;
st42:
	if ( ++p == pe )
		goto _test_eof42;
case 42:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st40;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st40;
	} else
		goto st40;
	goto st0;
tr67:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st43;
st43:
	if ( ++p == pe )
		goto _test_eof43;
case 43:
#line 1416 "unicorn_http.c"
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto tr71;
		case 58: goto st44;
		case 60: goto st0;
		case 64: goto st39;
		case 95: goto st43;
		case 127: goto st0;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 57 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st43;
		} else
			goto st43;
	} else
		goto st43;
	goto st40;
st44:
	if ( ++p == pe )
		goto _test_eof44;
case 44:
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto tr71;
		case 60: goto st0;
		case 64: goto st39;
		case 127: goto st0;
	}
	if ( (*p) < 34 ) {
		if ( 0 <= (*p) && (*p) <= 32 )
			goto st0;
	} else if ( (*p) > 35 ) {
		if ( (*p) > 57 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) >= 48 )
			goto st44;
	} else
		goto st0;
	goto st40;
tr68:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st45;
st45:
	if ( ++p == pe )
		goto _test_eof45;
case 45:
#line 1475 "unicorn_http.c"
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto st0;
		case 60: goto st0;
		case 64: goto st39;
		case 127: goto st0;
	}
	if ( (*p) < 48 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 58 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) > 70 ) {
			if ( 97 <= (*p) && (*p) <= 102 )
				goto st46;
		} else
			goto st46;
	} else
		goto st46;
	goto st40;
st46:
	if ( ++p == pe )
		goto _test_eof46;
case 46:
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto st0;
		case 60: goto st0;
		case 64: goto st39;
		case 93: goto st47;
		case 127: goto st0;
	}
	if ( (*p) < 48 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 58 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) > 70 ) {
			if ( 97 <= (*p) && (*p) <= 102 )
				goto st46;
		} else
			goto st46;
	} else
		goto st46;
	goto st40;
st47:
	if ( ++p == pe )
		goto _test_eof47;
case 47:
	switch( (*p) ) {
		case 37: goto st41;
		case 47: goto tr71;
		case 58: goto st44;
		case 60: goto st0;
		case 64: goto st39;
		case 127: goto st0;
	}
	if ( (*p) < 34 ) {
		if ( 0 <= (*p) && (*p) <= 32 )
			goto st0;
	} else if ( (*p) > 35 ) {
		if ( 62 <= (*p) && (*p) <= 63 )
			goto st0;
	} else
		goto st0;
	goto st40;
tr62:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st48;
st48:
	if ( ++p == pe )
		goto _test_eof48;
case 48:
#line 1560 "unicorn_http.c"
	if ( (*p) == 58 )
		goto tr61;
	goto st0;
st49:
	if ( ++p == pe )
		goto _test_eof49;
case 49:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st50;
		case 124: goto st50;
		case 126: goto st50;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st50;
		} else if ( (*p) >= 35 )
			goto st50;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st50;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st50;
		} else
			goto st50;
	} else
		goto st50;
	goto st0;
st50:
	if ( ++p == pe )
		goto _test_eof50;
case 50:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st51;
		case 124: goto st51;
		case 126: goto st51;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st51;
		} else if ( (*p) >= 35 )
			goto st51;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st51;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st51;
		} else
			goto st51;
	} else
		goto st51;
	goto st0;
st51:
	if ( ++p == pe )
		goto _test_eof51;
case 51:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st52;
		case 124: goto st52;
		case 126: goto st52;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st52;
		} else if ( (*p) >= 35 )
			goto st52;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st52;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st52;
		} else
			goto st52;
	} else
		goto st52;
	goto st0;
st52:
	if ( ++p == pe )
		goto _test_eof52;
case 52:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st53;
		case 124: goto st53;
		case 126: goto st53;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st53;
		} else if ( (*p) >= 35 )
			goto st53;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st53;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st53;
		} else
			goto st53;
	} else
		goto st53;
	goto st0;
st53:
	if ( ++p == pe )
		goto _test_eof53;
case 53:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st54;
		case 124: goto st54;
		case 126: goto st54;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st54;
		} else if ( (*p) >= 35 )
			goto st54;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st54;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st54;
		} else
			goto st54;
	} else
		goto st54;
	goto st0;
st54:
	if ( ++p == pe )
		goto _test_eof54;
case 54:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st55;
		case 124: goto st55;
		case 126: goto st55;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st55;
		} else if ( (*p) >= 35 )
			goto st55;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st55;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st55;
		} else
			goto st55;
	} else
		goto st55;
	goto st0;
st55:
	if ( ++p == pe )
		goto _test_eof55;
case 55:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st56;
		case 124: goto st56;
		case 126: goto st56;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st56;
		} else if ( (*p) >= 35 )
			goto st56;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st56;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st56;
		} else
			goto st56;
	} else
		goto st56;
	goto st0;
st56:
	if ( ++p == pe )
		goto _test_eof56;
case 56:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st57;
		case 124: goto st57;
		case 126: goto st57;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st57;
		} else if ( (*p) >= 35 )
			goto st57;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st57;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st57;
		} else
			goto st57;
	} else
		goto st57;
	goto st0;
st57:
	if ( ++p == pe )
		goto _test_eof57;
case 57:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st58;
		case 124: goto st58;
		case 126: goto st58;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st58;
		} else if ( (*p) >= 35 )
			goto st58;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st58;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st58;
		} else
			goto st58;
	} else
		goto st58;
	goto st0;
st58:
	if ( ++p == pe )
		goto _test_eof58;
case 58:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st59;
		case 124: goto st59;
		case 126: goto st59;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st59;
		} else if ( (*p) >= 35 )
			goto st59;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st59;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st59;
		} else
			goto st59;
	} else
		goto st59;
	goto st0;
st59:
	if ( ++p == pe )
		goto _test_eof59;
case 59:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st60;
		case 124: goto st60;
		case 126: goto st60;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st60;
		} else if ( (*p) >= 35 )
			goto st60;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st60;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st60;
		} else
			goto st60;
	} else
		goto st60;
	goto st0;
st60:
	if ( ++p == pe )
		goto _test_eof60;
case 60:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st61;
		case 124: goto st61;
		case 126: goto st61;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st61;
		} else if ( (*p) >= 35 )
			goto st61;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st61;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st61;
		} else
			goto st61;
	} else
		goto st61;
	goto st0;
st61:
	if ( ++p == pe )
		goto _test_eof61;
case 61:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st62;
		case 124: goto st62;
		case 126: goto st62;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st62;
		} else if ( (*p) >= 35 )
			goto st62;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st62;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st62;
		} else
			goto st62;
	} else
		goto st62;
	goto st0;
st62:
	if ( ++p == pe )
		goto _test_eof62;
case 62:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st63;
		case 124: goto st63;
		case 126: goto st63;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st63;
		} else if ( (*p) >= 35 )
			goto st63;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st63;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st63;
		} else
			goto st63;
	} else
		goto st63;
	goto st0;
st63:
	if ( ++p == pe )
		goto _test_eof63;
case 63:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st64;
		case 124: goto st64;
		case 126: goto st64;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st64;
		} else if ( (*p) >= 35 )
			goto st64;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st64;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st64;
		} else
			goto st64;
	} else
		goto st64;
	goto st0;
st64:
	if ( ++p == pe )
		goto _test_eof64;
case 64:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st65;
		case 124: goto st65;
		case 126: goto st65;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st65;
		} else if ( (*p) >= 35 )
			goto st65;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st65;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st65;
		} else
			goto st65;
	} else
		goto st65;
	goto st0;
st65:
	if ( ++p == pe )
		goto _test_eof65;
case 65:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st66;
		case 124: goto st66;
		case 126: goto st66;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st66;
		} else if ( (*p) >= 35 )
			goto st66;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st66;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st66;
		} else
			goto st66;
	} else
		goto st66;
	goto st0;
st66:
	if ( ++p == pe )
		goto _test_eof66;
case 66:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st67;
		case 124: goto st67;
		case 126: goto st67;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st67;
		} else if ( (*p) >= 35 )
			goto st67;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st67;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st67;
		} else
			goto st67;
	} else
		goto st67;
	goto st0;
st67:
	if ( ++p == pe )
		goto _test_eof67;
case 67:
	if ( (*p) == 32 )
		goto tr3;
	goto st0;
tr2:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st68;
st68:
	if ( ++p == pe )
		goto _test_eof68;
case 68:
#line 2083 "unicorn_http.c"
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st49;
		case 69: goto st69;
		case 124: goto st49;
		case 126: goto st49;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st49;
		} else if ( (*p) >= 35 )
			goto st49;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st49;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st49;
		} else
			goto st49;
	} else
		goto st49;
	goto st0;
st69:
	if ( ++p == pe )
		goto _test_eof69;
case 69:
	switch( (*p) ) {
		case 32: goto tr3;
		case 33: goto st50;
		case 84: goto st70;
		case 124: goto st50;
		case 126: goto st50;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st50;
		} else if ( (*p) >= 35 )
			goto st50;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st50;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st50;
		} else
			goto st50;
	} else
		goto st50;
	goto st0;
st70:
	if ( ++p == pe )
		goto _test_eof70;
case 70:
	switch( (*p) ) {
		case 32: goto tr95;
		case 33: goto st51;
		case 124: goto st51;
		case 126: goto st51;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st51;
		} else if ( (*p) >= 35 )
			goto st51;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st51;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st51;
		} else
			goto st51;
	} else
		goto st51;
	goto st0;
tr95:
#line 327 "unicorn_http.rl"
	{ request_method(hp, PTR_TO(mark), LEN(mark, p)); }
	goto st71;
st71:
	if ( ++p == pe )
		goto _test_eof71;
case 71:
#line 2174 "unicorn_http.c"
	switch( (*p) ) {
		case 42: goto tr96;
		case 47: goto tr97;
		case 72: goto tr98;
		case 104: goto tr98;
	}
	goto st0;
tr96:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st72;
st72:
	if ( ++p == pe )
		goto _test_eof72;
case 72:
#line 2190 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto tr99;
		case 32: goto tr8;
		case 35: goto tr100;
	}
	goto st0;
tr100:
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st73;
tr110:
#line 357 "unicorn_http.rl"
	{
    VALUE val;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_PATH);
    val = rb_hash_aset(hp->env, g_request_path, STR_NEW(mark, p));

    /* rack says PATH_INFO must start with "/" or be empty */
    if (!STR_CSTR_EQ(val, "*"))
      rb_hash_aset(hp->env, g_path_info, val);
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st73;
tr116:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st73;
tr120:
#line 352 "unicorn_http.rl"
	{
    VALIDATE_MAX_URI_LENGTH(LEN(start.query, p), QUERY_STRING);
    rb_hash_aset(hp->env, g_query_string, STR_NEW(start.query, p));
  }
#line 332 "unicorn_http.rl"
	{
    VALUE str;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_URI);
    str = rb_hash_aset(hp->env, g_request_uri, STR_NEW(mark, p));
    /*
     * "OPTIONS * HTTP/1.1\r\n" is a valid request, but we can't have '*'
     * in REQUEST_PATH or PATH_INFO or else Rack::Lint will complain
     */
    if (STR_CSTR_EQ(str, "*")) {
      str = rb_str_new(NULL, 0);
      rb_hash_aset(hp->env, g_path_info, str);
      rb_hash_aset(hp->env, g_request_path, str);
    }
  }
	goto st73;
st73:
	if ( ++p == pe )
		goto _test_eof73;
case 73:
#line 2296 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto tr102;
		case 32: goto tr37;
		case 35: goto st0;
		case 37: goto tr103;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto tr101;
tr101:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st74;
st74:
	if ( ++p == pe )
		goto _test_eof74;
case 74:
#line 2315 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto tr105;
		case 32: goto tr40;
		case 35: goto st0;
		case 37: goto st75;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st74;
tr103:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st75;
st75:
	if ( ++p == pe )
		goto _test_eof75;
case 75:
#line 2334 "unicorn_http.c"
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st76;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st76;
	} else
		goto st76;
	goto st0;
st76:
	if ( ++p == pe )
		goto _test_eof76;
case 76:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st74;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st74;
	} else
		goto st74;
	goto st0;
tr97:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st77;
tr136:
#line 331 "unicorn_http.rl"
	{ rb_hash_aset(hp->env, g_http_host, STR_NEW(mark, p)); }
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st77;
st77:
	if ( ++p == pe )
		goto _test_eof77;
case 77:
#line 2371 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto tr109;
		case 32: goto tr44;
		case 35: goto tr110;
		case 37: goto st78;
		case 63: goto tr112;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st77;
st78:
	if ( ++p == pe )
		goto _test_eof78;
case 78:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st79;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st79;
	} else
		goto st79;
	goto st0;
st79:
	if ( ++p == pe )
		goto _test_eof79;
case 79:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st77;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st77;
	} else
		goto st77;
	goto st0;
tr112:
#line 357 "unicorn_http.rl"
	{
    VALUE val;

    VALIDATE_MAX_URI_LENGTH(LEN(mark, p), REQUEST_PATH);
    val = rb_hash_aset(hp->env, g_request_path, STR_NEW(mark, p));

    /* rack says PATH_INFO must start with "/" or be empty */
    if (!STR_CSTR_EQ(val, "*"))
      rb_hash_aset(hp->env, g_path_info, val);
  }
	goto st80;
st80:
	if ( ++p == pe )
		goto _test_eof80;
case 80:
#line 2426 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto tr115;
		case 32: goto tr50;
		case 35: goto tr116;
		case 37: goto tr117;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto tr114;
tr114:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
	goto st81;
st81:
	if ( ++p == pe )
		goto _test_eof81;
case 81:
#line 2445 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto tr119;
		case 32: goto tr54;
		case 35: goto tr120;
		case 37: goto st82;
		case 127: goto st0;
	}
	if ( 0 <= (*p) && (*p) <= 31 )
		goto st0;
	goto st81;
tr117:
#line 351 "unicorn_http.rl"
	{MARK(start.query, p); }
	goto st82;
st82:
	if ( ++p == pe )
		goto _test_eof82;
case 82:
#line 2464 "unicorn_http.c"
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st83;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st83;
	} else
		goto st83;
	goto st0;
st83:
	if ( ++p == pe )
		goto _test_eof83;
case 83:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st81;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st81;
	} else
		goto st81;
	goto st0;
tr98:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st84;
st84:
	if ( ++p == pe )
		goto _test_eof84;
case 84:
#line 2497 "unicorn_http.c"
	switch( (*p) ) {
		case 84: goto tr123;
		case 116: goto tr123;
	}
	goto st0;
tr123:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st85;
st85:
	if ( ++p == pe )
		goto _test_eof85;
case 85:
#line 2511 "unicorn_http.c"
	switch( (*p) ) {
		case 84: goto tr124;
		case 116: goto tr124;
	}
	goto st0;
tr124:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st86;
st86:
	if ( ++p == pe )
		goto _test_eof86;
case 86:
#line 2525 "unicorn_http.c"
	switch( (*p) ) {
		case 80: goto tr125;
		case 112: goto tr125;
	}
	goto st0;
tr125:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st87;
st87:
	if ( ++p == pe )
		goto _test_eof87;
case 87:
#line 2539 "unicorn_http.c"
	switch( (*p) ) {
		case 58: goto tr126;
		case 83: goto tr127;
		case 115: goto tr127;
	}
	goto st0;
tr126:
#line 328 "unicorn_http.rl"
	{
    rb_hash_aset(hp->env, g_rack_url_scheme, STR_NEW(mark, p));
  }
	goto st88;
st88:
	if ( ++p == pe )
		goto _test_eof88;
case 88:
#line 2556 "unicorn_http.c"
	if ( (*p) == 47 )
		goto st89;
	goto st0;
st89:
	if ( ++p == pe )
		goto _test_eof89;
case 89:
	if ( (*p) == 47 )
		goto st90;
	goto st0;
st90:
	if ( ++p == pe )
		goto _test_eof90;
case 90:
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto st0;
		case 60: goto st0;
		case 91: goto tr133;
		case 95: goto tr132;
		case 127: goto st0;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 57 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 64 )
				goto st0;
		} else if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr132;
		} else
			goto tr132;
	} else
		goto tr132;
	goto st91;
st91:
	if ( ++p == pe )
		goto _test_eof91;
case 91:
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto st0;
		case 60: goto st0;
		case 64: goto st90;
		case 127: goto st0;
	}
	if ( (*p) < 34 ) {
		if ( 0 <= (*p) && (*p) <= 32 )
			goto st0;
	} else if ( (*p) > 35 ) {
		if ( 62 <= (*p) && (*p) <= 63 )
			goto st0;
	} else
		goto st0;
	goto st91;
st92:
	if ( ++p == pe )
		goto _test_eof92;
case 92:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st93;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st93;
	} else
		goto st93;
	goto st0;
st93:
	if ( ++p == pe )
		goto _test_eof93;
case 93:
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st91;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st91;
	} else
		goto st91;
	goto st0;
tr132:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st94;
st94:
	if ( ++p == pe )
		goto _test_eof94;
case 94:
#line 2651 "unicorn_http.c"
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto tr136;
		case 58: goto st95;
		case 60: goto st0;
		case 64: goto st90;
		case 95: goto st94;
		case 127: goto st0;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 57 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto st94;
		} else
			goto st94;
	} else
		goto st94;
	goto st91;
st95:
	if ( ++p == pe )
		goto _test_eof95;
case 95:
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto tr136;
		case 60: goto st0;
		case 64: goto st90;
		case 127: goto st0;
	}
	if ( (*p) < 34 ) {
		if ( 0 <= (*p) && (*p) <= 32 )
			goto st0;
	} else if ( (*p) > 35 ) {
		if ( (*p) > 57 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) >= 48 )
			goto st95;
	} else
		goto st0;
	goto st91;
tr133:
#line 318 "unicorn_http.rl"
	{MARK(mark, p); }
	goto st96;
st96:
	if ( ++p == pe )
		goto _test_eof96;
case 96:
#line 2710 "unicorn_http.c"
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto st0;
		case 60: goto st0;
		case 64: goto st90;
		case 127: goto st0;
	}
	if ( (*p) < 48 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 58 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) > 70 ) {
			if ( 97 <= (*p) && (*p) <= 102 )
				goto st97;
		} else
			goto st97;
	} else
		goto st97;
	goto st91;
st97:
	if ( ++p == pe )
		goto _test_eof97;
case 97:
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto st0;
		case 60: goto st0;
		case 64: goto st90;
		case 93: goto st98;
		case 127: goto st0;
	}
	if ( (*p) < 48 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 35 )
				goto st0;
		} else if ( (*p) >= 0 )
			goto st0;
	} else if ( (*p) > 58 ) {
		if ( (*p) < 65 ) {
			if ( 62 <= (*p) && (*p) <= 63 )
				goto st0;
		} else if ( (*p) > 70 ) {
			if ( 97 <= (*p) && (*p) <= 102 )
				goto st97;
		} else
			goto st97;
	} else
		goto st97;
	goto st91;
st98:
	if ( ++p == pe )
		goto _test_eof98;
case 98:
	switch( (*p) ) {
		case 37: goto st92;
		case 47: goto tr136;
		case 58: goto st95;
		case 60: goto st0;
		case 64: goto st90;
		case 127: goto st0;
	}
	if ( (*p) < 34 ) {
		if ( 0 <= (*p) && (*p) <= 32 )
			goto st0;
	} else if ( (*p) > 35 ) {
		if ( 62 <= (*p) && (*p) <= 63 )
			goto st0;
	} else
		goto st0;
	goto st91;
tr127:
#line 322 "unicorn_http.rl"
	{ downcase_char(deconst(p)); }
	goto st99;
st99:
	if ( ++p == pe )
		goto _test_eof99;
case 99:
#line 2795 "unicorn_http.c"
	if ( (*p) == 58 )
		goto tr126;
	goto st0;
st100:
	if ( ++p == pe )
		goto _test_eof100;
case 100:
	if ( (*p) == 48 )
		goto tr140;
	if ( (*p) < 65 ) {
		if ( 49 <= (*p) && (*p) <= 57 )
			goto tr141;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto tr141;
	} else
		goto tr141;
	goto st0;
tr140:
#line 367 "unicorn_http.rl"
	{
    hp->len.chunk = step_incr(hp->len.chunk, (*p), 16);
    if (hp->len.chunk < 0)
      parser_raise(eHttpParserError, "invalid chunk size");
  }
	goto st101;
st101:
	if ( ++p == pe )
		goto _test_eof101;
case 101:
#line 2826 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto st102;
		case 48: goto tr140;
		case 59: goto st111;
	}
	if ( (*p) < 65 ) {
		if ( 49 <= (*p) && (*p) <= 57 )
			goto tr141;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto tr141;
	} else
		goto tr141;
	goto st0;
st102:
	if ( ++p == pe )
		goto _test_eof102;
case 102:
	if ( (*p) == 10 )
		goto tr144;
	goto st0;
tr144:
#line 396 "unicorn_http.rl"
	{
    HP_FL_SET(hp, INTRAILER);
    cs = http_parser_en_Trailers;
    ++p;
    assert(p <= pe && "buffer overflow after chunked body");
    goto post_exec;
  }
	goto st123;
st123:
	if ( ++p == pe )
		goto _test_eof123;
case 123:
#line 2862 "unicorn_http.c"
	goto st0;
tr141:
#line 367 "unicorn_http.rl"
	{
    hp->len.chunk = step_incr(hp->len.chunk, (*p), 16);
    if (hp->len.chunk < 0)
      parser_raise(eHttpParserError, "invalid chunk size");
  }
	goto st103;
st103:
	if ( ++p == pe )
		goto _test_eof103;
case 103:
#line 2876 "unicorn_http.c"
	switch( (*p) ) {
		case 13: goto st104;
		case 59: goto st108;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr141;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto tr141;
	} else
		goto tr141;
	goto st0;
st104:
	if ( ++p == pe )
		goto _test_eof104;
case 104:
	if ( (*p) == 10 )
		goto st105;
	goto st0;
st105:
	if ( ++p == pe )
		goto _test_eof105;
case 105:
	goto tr148;
tr148:
#line 404 "unicorn_http.rl"
	{
  skip_chunk_data_hack: {
    size_t nr = MIN((size_t)hp->len.chunk, REMAINING);
    memcpy(RSTRING_PTR(hp->cont) + hp->s.dest_offset, p, nr);
    hp->s.dest_offset += nr;
    hp->len.chunk -= nr;
    p += nr;
    assert(hp->len.chunk >= 0 && "negative chunk length");
    if ((size_t)hp->len.chunk > REMAINING) {
      HP_FL_SET(hp, INCHUNK);
      goto post_exec;
    } else {
      p--;
      {goto st106;}
    }
  }}
	goto st106;
st106:
	if ( ++p == pe )
		goto _test_eof106;
case 106:
#line 2925 "unicorn_http.c"
	if ( (*p) == 13 )
		goto st107;
	goto st0;
st107:
	if ( ++p == pe )
		goto _test_eof107;
case 107:
	if ( (*p) == 10 )
		goto st100;
	goto st0;
st108:
	if ( ++p == pe )
		goto _test_eof108;
case 108:
	switch( (*p) ) {
		case 13: goto st104;
		case 32: goto st108;
		case 33: goto st109;
		case 59: goto st108;
		case 61: goto st110;
		case 124: goto st109;
		case 126: goto st109;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st109;
		} else if ( (*p) >= 35 )
			goto st109;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st109;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st109;
		} else
			goto st109;
	} else
		goto st109;
	goto st0;
st109:
	if ( ++p == pe )
		goto _test_eof109;
case 109:
	switch( (*p) ) {
		case 13: goto st104;
		case 33: goto st109;
		case 59: goto st108;
		case 61: goto st110;
		case 124: goto st109;
		case 126: goto st109;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st109;
		} else if ( (*p) >= 35 )
			goto st109;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st109;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st109;
		} else
			goto st109;
	} else
		goto st109;
	goto st0;
st110:
	if ( ++p == pe )
		goto _test_eof110;
case 110:
	switch( (*p) ) {
		case 13: goto st104;
		case 33: goto st110;
		case 59: goto st108;
		case 124: goto st110;
		case 126: goto st110;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st110;
		} else if ( (*p) >= 35 )
			goto st110;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st110;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st110;
		} else
			goto st110;
	} else
		goto st110;
	goto st0;
st111:
	if ( ++p == pe )
		goto _test_eof111;
case 111:
	switch( (*p) ) {
		case 13: goto st102;
		case 32: goto st111;
		case 33: goto st112;
		case 59: goto st111;
		case 61: goto st113;
		case 124: goto st112;
		case 126: goto st112;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st112;
		} else if ( (*p) >= 35 )
			goto st112;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st112;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st112;
		} else
			goto st112;
	} else
		goto st112;
	goto st0;
st112:
	if ( ++p == pe )
		goto _test_eof112;
case 112:
	switch( (*p) ) {
		case 13: goto st102;
		case 33: goto st112;
		case 59: goto st111;
		case 61: goto st113;
		case 124: goto st112;
		case 126: goto st112;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st112;
		} else if ( (*p) >= 35 )
			goto st112;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st112;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st112;
		} else
			goto st112;
	} else
		goto st112;
	goto st0;
st113:
	if ( ++p == pe )
		goto _test_eof113;
case 113:
	switch( (*p) ) {
		case 13: goto st102;
		case 33: goto st113;
		case 59: goto st111;
		case 124: goto st113;
		case 126: goto st113;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st113;
		} else if ( (*p) >= 35 )
			goto st113;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st113;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st113;
		} else
			goto st113;
	} else
		goto st113;
	goto st0;
st114:
	if ( ++p == pe )
		goto _test_eof114;
case 114:
	switch( (*p) ) {
		case 9: goto st115;
		case 13: goto st118;
		case 32: goto st115;
		case 33: goto tr157;
		case 124: goto tr157;
		case 126: goto tr157;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr157;
		} else if ( (*p) >= 35 )
			goto tr157;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr157;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr157;
		} else
			goto tr157;
	} else
		goto tr157;
	goto st0;
tr159:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st115;
st115:
	if ( ++p == pe )
		goto _test_eof115;
case 115:
#line 3154 "unicorn_http.c"
	switch( (*p) ) {
		case 9: goto tr159;
		case 13: goto tr160;
		case 32: goto tr159;
	}
	goto tr158;
tr158:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st116;
st116:
	if ( ++p == pe )
		goto _test_eof116;
case 116:
#line 3169 "unicorn_http.c"
	if ( (*p) == 13 )
		goto tr162;
	goto st116;
tr160:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
#line 326 "unicorn_http.rl"
	{ write_cont_value(hp, buffer, p); }
	goto st117;
tr162:
#line 326 "unicorn_http.rl"
	{ write_cont_value(hp, buffer, p); }
	goto st117;
tr169:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
#line 325 "unicorn_http.rl"
	{ write_value(hp, buffer, p); }
	goto st117;
tr171:
#line 325 "unicorn_http.rl"
	{ write_value(hp, buffer, p); }
	goto st117;
st117:
	if ( ++p == pe )
		goto _test_eof117;
case 117:
#line 3197 "unicorn_http.c"
	if ( (*p) == 10 )
		goto st114;
	goto st0;
st118:
	if ( ++p == pe )
		goto _test_eof118;
case 118:
	if ( (*p) == 10 )
		goto tr164;
	goto st0;
tr164:
#line 391 "unicorn_http.rl"
	{
    cs = http_parser_first_final;
    goto post_exec;
  }
	goto st124;
st124:
	if ( ++p == pe )
		goto _test_eof124;
case 124:
#line 3219 "unicorn_http.c"
	goto st0;
tr157:
#line 320 "unicorn_http.rl"
	{ MARK(start.field, p); }
#line 321 "unicorn_http.rl"
	{ snake_upcase_char(deconst(p)); }
	goto st119;
tr165:
#line 321 "unicorn_http.rl"
	{ snake_upcase_char(deconst(p)); }
	goto st119;
st119:
	if ( ++p == pe )
		goto _test_eof119;
case 119:
#line 3235 "unicorn_http.c"
	switch( (*p) ) {
		case 33: goto tr165;
		case 58: goto tr166;
		case 124: goto tr165;
		case 126: goto tr165;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr165;
		} else if ( (*p) >= 35 )
			goto tr165;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr165;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr165;
		} else
			goto tr165;
	} else
		goto tr165;
	goto st0;
tr168:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st120;
tr166:
#line 323 "unicorn_http.rl"
	{ hp->s.field_len = LEN(start.field, p); }
	goto st120;
st120:
	if ( ++p == pe )
		goto _test_eof120;
case 120:
#line 3272 "unicorn_http.c"
	switch( (*p) ) {
		case 9: goto tr168;
		case 13: goto tr169;
		case 32: goto tr168;
	}
	goto tr167;
tr167:
#line 324 "unicorn_http.rl"
	{ MARK(mark, p); }
	goto st121;
st121:
	if ( ++p == pe )
		goto _test_eof121;
case 121:
#line 3287 "unicorn_http.c"
	if ( (*p) == 13 )
		goto tr171;
	goto st121;
	}
	_test_eof2: cs = 2; goto _test_eof; 
	_test_eof3: cs = 3; goto _test_eof; 
	_test_eof4: cs = 4; goto _test_eof; 
	_test_eof5: cs = 5; goto _test_eof; 
	_test_eof6: cs = 6; goto _test_eof; 
	_test_eof7: cs = 7; goto _test_eof; 
	_test_eof8: cs = 8; goto _test_eof; 
	_test_eof9: cs = 9; goto _test_eof; 
	_test_eof10: cs = 10; goto _test_eof; 
	_test_eof11: cs = 11; goto _test_eof; 
	_test_eof12: cs = 12; goto _test_eof; 
	_test_eof13: cs = 13; goto _test_eof; 
	_test_eof14: cs = 14; goto _test_eof; 
	_test_eof15: cs = 15; goto _test_eof; 
	_test_eof16: cs = 16; goto _test_eof; 
	_test_eof17: cs = 17; goto _test_eof; 
	_test_eof18: cs = 18; goto _test_eof; 
	_test_eof122: cs = 122; goto _test_eof; 
	_test_eof19: cs = 19; goto _test_eof; 
	_test_eof20: cs = 20; goto _test_eof; 
	_test_eof21: cs = 21; goto _test_eof; 
	_test_eof22: cs = 22; goto _test_eof; 
	_test_eof23: cs = 23; goto _test_eof; 
	_test_eof24: cs = 24; goto _test_eof; 
	_test_eof25: cs = 25; goto _test_eof; 
	_test_eof26: cs = 26; goto _test_eof; 
	_test_eof27: cs = 27; goto _test_eof; 
	_test_eof28: cs = 28; goto _test_eof; 
	_test_eof29: cs = 29; goto _test_eof; 
	_test_eof30: cs = 30; goto _test_eof; 
	_test_eof31: cs = 31; goto _test_eof; 
	_test_eof32: cs = 32; goto _test_eof; 
	_test_eof33: cs = 33; goto _test_eof; 
	_test_eof34: cs = 34; goto _test_eof; 
	_test_eof35: cs = 35; goto _test_eof; 
	_test_eof36: cs = 36; goto _test_eof; 
	_test_eof37: cs = 37; goto _test_eof; 
	_test_eof38: cs = 38; goto _test_eof; 
	_test_eof39: cs = 39; goto _test_eof; 
	_test_eof40: cs = 40; goto _test_eof; 
	_test_eof41: cs = 41; goto _test_eof; 
	_test_eof42: cs = 42; goto _test_eof; 
	_test_eof43: cs = 43; goto _test_eof; 
	_test_eof44: cs = 44; goto _test_eof; 
	_test_eof45: cs = 45; goto _test_eof; 
	_test_eof46: cs = 46; goto _test_eof; 
	_test_eof47: cs = 47; goto _test_eof; 
	_test_eof48: cs = 48; goto _test_eof; 
	_test_eof49: cs = 49; goto _test_eof; 
	_test_eof50: cs = 50; goto _test_eof; 
	_test_eof51: cs = 51; goto _test_eof; 
	_test_eof52: cs = 52; goto _test_eof; 
	_test_eof53: cs = 53; goto _test_eof; 
	_test_eof54: cs = 54; goto _test_eof; 
	_test_eof55: cs = 55; goto _test_eof; 
	_test_eof56: cs = 56; goto _test_eof; 
	_test_eof57: cs = 57; goto _test_eof; 
	_test_eof58: cs = 58; goto _test_eof; 
	_test_eof59: cs = 59; goto _test_eof; 
	_test_eof60: cs = 60; goto _test_eof; 
	_test_eof61: cs = 61; goto _test_eof; 
	_test_eof62: cs = 62; goto _test_eof; 
	_test_eof63: cs = 63; goto _test_eof; 
	_test_eof64: cs = 64; goto _test_eof; 
	_test_eof65: cs = 65; goto _test_eof; 
	_test_eof66: cs = 66; goto _test_eof; 
	_test_eof67: cs = 67; goto _test_eof; 
	_test_eof68: cs = 68; goto _test_eof; 
	_test_eof69: cs = 69; goto _test_eof; 
	_test_eof70: cs = 70; goto _test_eof; 
	_test_eof71: cs = 71; goto _test_eof; 
	_test_eof72: cs = 72; goto _test_eof; 
	_test_eof73: cs = 73; goto _test_eof; 
	_test_eof74: cs = 74; goto _test_eof; 
	_test_eof75: cs = 75; goto _test_eof; 
	_test_eof76: cs = 76; goto _test_eof; 
	_test_eof77: cs = 77; goto _test_eof; 
	_test_eof78: cs = 78; goto _test_eof; 
	_test_eof79: cs = 79; goto _test_eof; 
	_test_eof80: cs = 80; goto _test_eof; 
	_test_eof81: cs = 81; goto _test_eof; 
	_test_eof82: cs = 82; goto _test_eof; 
	_test_eof83: cs = 83; goto _test_eof; 
	_test_eof84: cs = 84; goto _test_eof; 
	_test_eof85: cs = 85; goto _test_eof; 
	_test_eof86: cs = 86; goto _test_eof; 
	_test_eof87: cs = 87; goto _test_eof; 
	_test_eof88: cs = 88; goto _test_eof; 
	_test_eof89: cs = 89; goto _test_eof; 
	_test_eof90: cs = 90; goto _test_eof; 
	_test_eof91: cs = 91; goto _test_eof; 
	_test_eof92: cs = 92; goto _test_eof; 
	_test_eof93: cs = 93; goto _test_eof; 
	_test_eof94: cs = 94; goto _test_eof; 
	_test_eof95: cs = 95; goto _test_eof; 
	_test_eof96: cs = 96; goto _test_eof; 
	_test_eof97: cs = 97; goto _test_eof; 
	_test_eof98: cs = 98; goto _test_eof; 
	_test_eof99: cs = 99; goto _test_eof; 
	_test_eof100: cs = 100; goto _test_eof; 
	_test_eof101: cs = 101; goto _test_eof; 
	_test_eof102: cs = 102; goto _test_eof; 
	_test_eof123: cs = 123; goto _test_eof; 
	_test_eof103: cs = 103; goto _test_eof; 
	_test_eof104: cs = 104; goto _test_eof; 
	_test_eof105: cs = 105; goto _test_eof; 
	_test_eof106: cs = 106; goto _test_eof; 
	_test_eof107: cs = 107; goto _test_eof; 
	_test_eof108: cs = 108; goto _test_eof; 
	_test_eof109: cs = 109; goto _test_eof; 
	_test_eof110: cs = 110; goto _test_eof; 
	_test_eof111: cs = 111; goto _test_eof; 
	_test_eof112: cs = 112; goto _test_eof; 
	_test_eof113: cs = 113; goto _test_eof; 
	_test_eof114: cs = 114; goto _test_eof; 
	_test_eof115: cs = 115; goto _test_eof; 
	_test_eof116: cs = 116; goto _test_eof; 
	_test_eof117: cs = 117; goto _test_eof; 
	_test_eof118: cs = 118; goto _test_eof; 
	_test_eof124: cs = 124; goto _test_eof; 
	_test_eof119: cs = 119; goto _test_eof; 
	_test_eof120: cs = 120; goto _test_eof; 
	_test_eof121: cs = 121; goto _test_eof; 

	_test_eof: {}
	_out: {}
	}

#line 465 "unicorn_http.rl"
post_exec: /* "_out:" also goes here */
  if (hp->cs != http_parser_error)
    hp->cs = cs;
  hp->offset = p - buffer;

  assert(p <= pe && "buffer overflow after parsing execute");
  assert(hp->offset <= len && "offset longer than length");
}

static struct http_parser *data_get(VALUE self)
{
  struct http_parser *hp;

  Data_Get_Struct(self, struct http_parser, hp);
  assert(hp && "failed to extract http_parser struct");
  return hp;
}

/*
 * set rack.url_scheme to "https" or "http", no others are allowed by Rack
 * this resembles the Rack::Request#scheme method as of rack commit
 * 35bb5ba6746b5d346de9202c004cc926039650c7
 */
static void set_url_scheme(VALUE env, VALUE *server_port)
{
  VALUE scheme = rb_hash_aref(env, g_rack_url_scheme);

  if (NIL_P(scheme)) {
    if (trust_x_forward == Qfalse) {
      scheme = g_http;
    } else {
      scheme = rb_hash_aref(env, g_http_x_forwarded_ssl);
      if (!NIL_P(scheme) && STR_CSTR_EQ(scheme, "on")) {
        *server_port = g_port_443;
        scheme = g_https;
      } else {
        scheme = rb_hash_aref(env, g_http_x_forwarded_proto);
        if (NIL_P(scheme)) {
          scheme = g_http;
        } else {
          long len = RSTRING_LEN(scheme);
          if (len >= 5 && !memcmp(RSTRING_PTR(scheme), "https", 5)) {
            if (len != 5)
              scheme = g_https;
            *server_port = g_port_443;
          } else {
            scheme = g_http;
          }
        }
      }
    }
    rb_hash_aset(env, g_rack_url_scheme, scheme);
  } else if (STR_CSTR_EQ(scheme, "https")) {
    *server_port = g_port_443;
  } else {
    assert(*server_port == g_port_80 && "server_port not set");
  }
}

/*
 * Parse and set the SERVER_NAME and SERVER_PORT variables
 * Not supporting X-Forwarded-Host/X-Forwarded-Port in here since
 * anybody who needs them is using an unsupported configuration and/or
 * incompetent.  Rack::Request will handle X-Forwarded-{Port,Host} just
 * fine.
 */
static void set_server_vars(VALUE env, VALUE *server_port)
{
  VALUE server_name = g_localhost;
  VALUE host = rb_hash_aref(env, g_http_host);

  if (!NIL_P(host)) {
    char *host_ptr = RSTRING_PTR(host);
    long host_len = RSTRING_LEN(host);
    char *colon;

    if (*host_ptr == '[') { /* ipv6 address format */
      char *rbracket = memchr(host_ptr + 1, ']', host_len - 1);

      if (rbracket)
        colon = (rbracket[1] == ':') ? rbracket + 1 : NULL;
      else
        colon = memchr(host_ptr + 1, ':', host_len - 1);
    } else {
      colon = memchr(host_ptr, ':', host_len);
    }

    if (colon) {
      long port_start = colon - host_ptr + 1;

      server_name = rb_str_substr(host, 0, colon - host_ptr);
      if ((host_len - port_start) > 0)
        *server_port = rb_str_substr(host, port_start, host_len);
    } else {
      server_name = host;
    }
  }
  rb_hash_aset(env, g_server_name, server_name);
  rb_hash_aset(env, g_server_port, *server_port);
}

static void finalize_header(struct http_parser *hp)
{
  VALUE server_port = g_port_80;

  set_url_scheme(hp->env, &server_port);
  set_server_vars(hp->env, &server_port);

  if (!HP_FL_TEST(hp, HASHEADER))
    rb_hash_aset(hp->env, g_server_protocol, g_http_09);

  /* rack requires QUERY_STRING */
  if (NIL_P(rb_hash_aref(hp->env, g_query_string)))
    rb_hash_aset(hp->env, g_query_string, rb_str_new(NULL, 0));
}

static void hp_mark(void *ptr)
{
  struct http_parser *hp = ptr;

  rb_gc_mark(hp->buf);
  rb_gc_mark(hp->env);
  rb_gc_mark(hp->cont);
}

static VALUE HttpParser_alloc(VALUE klass)
{
  struct http_parser *hp;
  return Data_Make_Struct(klass, struct http_parser, hp_mark, -1, hp);
}


/**
 * call-seq:
 *    parser.new => parser
 *
 * Creates a new parser.
 */
static VALUE HttpParser_init(VALUE self)
{
  struct http_parser *hp = data_get(self);

  http_parser_init(hp);
  hp->buf = rb_str_new(NULL, 0);
  hp->env = rb_hash_new();
  hp->nr_requests = keepalive_requests;

  return self;
}

/**
 * call-seq:
 *    parser.clear => parser
 *
 * Resets the parser to it's initial state so that you can reuse it
 * rather than making new ones.
 */
static VALUE HttpParser_clear(VALUE self)
{
  struct http_parser *hp = data_get(self);

  http_parser_init(hp);
  rb_funcall(hp->env, id_clear, 0);

  return self;
}

/**
 * call-seq:
 *    parser.dechunk! => parser
 *
 * Resets the parser to a state suitable for dechunking response bodies
 *
 */
static VALUE HttpParser_dechunk_bang(VALUE self)
{
  struct http_parser *hp = data_get(self);

  http_parser_init(hp);

  /*
   * we don't care about trailers in dechunk-only mode,
   * but if we did we'd set UH_FL_HASTRAILER and clear hp->env
   */
  if (0) {
    rb_funcall(hp->env, id_clear, 0);
    hp->flags = UH_FL_HASTRAILER;
  }

  hp->flags |= UH_FL_HASBODY | UH_FL_INBODY | UH_FL_CHUNKED;
  hp->cs = http_parser_en_ChunkedBody;

  return self;
}

/**
 * call-seq:
 *    parser.reset => nil
 *
 * Resets the parser to it's initial state so that you can reuse it
 * rather than making new ones.
 *
 * This method is deprecated and to be removed in Unicorn 4.x
 */
static VALUE HttpParser_reset(VALUE self)
{
  static int warned;

  if (!warned) {
    rb_warn("Unicorn::HttpParser#reset is deprecated; "
            "use Unicorn::HttpParser#clear instead");
  }
  HttpParser_clear(self);
  return Qnil;
}

static void advance_str(VALUE str, off_t nr)
{
  long len = RSTRING_LEN(str);

  if (len == 0)
    return;

  rb_str_modify(str);

  assert(nr <= len && "trying to advance past end of buffer");
  len -= nr;
  if (len > 0) /* unlikely, len is usually 0 */
    memmove(RSTRING_PTR(str), RSTRING_PTR(str) + nr, len);
  rb_str_set_len(str, len);
}

/**
 * call-seq:
 *   parser.content_length => nil or Integer
 *
 * Returns the number of bytes left to run through HttpParser#filter_body.
 * This will initially be the value of the "Content-Length" HTTP header
 * after header parsing is complete and will decrease in value as
 * HttpParser#filter_body is called for each chunk.  This should return
 * zero for requests with no body.
 *
 * This will return nil on "Transfer-Encoding: chunked" requests.
 */
static VALUE HttpParser_content_length(VALUE self)
{
  struct http_parser *hp = data_get(self);

  return HP_FL_TEST(hp, CHUNKED) ? Qnil : OFFT2NUM(hp->len.content);
}

/**
 * Document-method: parse
 * call-seq:
 *    parser.parse => env or nil
 *
 * Takes a Hash and a String of data, parses the String of data filling
 * in the Hash returning the Hash if parsing is finished, nil otherwise
 * When returning the env Hash, it may modify data to point to where
 * body processing should begin.
 *
 * Raises HttpParserError if there are parsing errors.
 */
static VALUE HttpParser_parse(VALUE self)
{
  struct http_parser *hp = data_get(self);
  VALUE data = hp->buf;

  if (HP_FL_TEST(hp, TO_CLEAR)) {
    http_parser_init(hp);
    rb_funcall(hp->env, id_clear, 0);
  }

  http_parser_execute(hp, RSTRING_PTR(data), RSTRING_LEN(data));
  if (hp->offset > MAX_HEADER_LEN)
    parser_raise(e413, "HTTP header is too large");

  if (hp->cs == http_parser_first_final ||
      hp->cs == http_parser_en_ChunkedBody) {
    advance_str(data, hp->offset + 1);
    hp->offset = 0;
    if (HP_FL_TEST(hp, INTRAILER))
      HP_FL_SET(hp, REQEOF);

    return hp->env;
  }

  if (hp->cs == http_parser_error)
    parser_raise(eHttpParserError, "Invalid HTTP format, parsing fails.");

  return Qnil;
}

/**
 * Document-method: parse
 * call-seq:
 *    parser.add_parse(buffer) => env or nil
 *
 * adds the contents of +buffer+ to the internal buffer and attempts to
 * continue parsing.  Returns the +env+ Hash on success or nil if more
 * data is needed.
 *
 * Raises HttpParserError if there are parsing errors.
 */
static VALUE HttpParser_add_parse(VALUE self, VALUE buffer)
{
  struct http_parser *hp = data_get(self);

  Check_Type(buffer, T_STRING);
  rb_str_buf_append(hp->buf, buffer);

  return HttpParser_parse(self);
}

/**
 * Document-method: trailers
 * call-seq:
 *    parser.trailers(req, data) => req or nil
 *
 * This is an alias for HttpParser#headers
 */

/**
 * Document-method: headers
 */
static VALUE HttpParser_headers(VALUE self, VALUE env, VALUE buf)
{
  struct http_parser *hp = data_get(self);

  hp->env = env;
  hp->buf = buf;

  return HttpParser_parse(self);
}

static int chunked_eof(struct http_parser *hp)
{
  return ((hp->cs == http_parser_first_final) || HP_FL_TEST(hp, INTRAILER));
}

/**
 * call-seq:
 *    parser.body_eof? => true or false
 *
 * Detects if we're done filtering the body or not.  This can be used
 * to detect when to stop calling HttpParser#filter_body.
 */
static VALUE HttpParser_body_eof(VALUE self)
{
  struct http_parser *hp = data_get(self);

  if (HP_FL_TEST(hp, CHUNKED))
    return chunked_eof(hp) ? Qtrue : Qfalse;

  return hp->len.content == 0 ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *    parser.keepalive? => true or false
 *
 * This should be used to detect if a request can really handle
 * keepalives and pipelining.  Currently, the rules are:
 *
 * 1. MUST be a GET or HEAD request
 * 2. MUST be HTTP/1.1 +or+ HTTP/1.0 with "Connection: keep-alive"
 * 3. MUST NOT have "Connection: close" set
 */
static VALUE HttpParser_keepalive(VALUE self)
{
  struct http_parser *hp = data_get(self);

  return HP_FL_ALL(hp, KEEPALIVE) ? Qtrue : Qfalse;
}

/**
 * call-seq:
 *    parser.next? => true or false
 *
 * Exactly like HttpParser#keepalive?, except it will reset the internal
 * parser state on next parse if it returns true.  It will also respect
 * the maximum *keepalive_requests* value and return false if that is
 * reached.
 */
static VALUE HttpParser_next(VALUE self)
{
  struct http_parser *hp = data_get(self);

  if ((HP_FL_ALL(hp, KEEPALIVE)) && (hp->nr_requests-- != 0)) {
    HP_FL_SET(hp, TO_CLEAR);
    return Qtrue;
  }
  return Qfalse;
}

/**
 * call-seq:
 *    parser.headers? => true or false
 *
 * This should be used to detect if a request has headers (and if
 * the response will have headers as well).  HTTP/0.9 requests
 * should return false, all subsequent HTTP versions will return true
 */
static VALUE HttpParser_has_headers(VALUE self)
{
  struct http_parser *hp = data_get(self);

  return HP_FL_TEST(hp, HASHEADER) ? Qtrue : Qfalse;
}

static VALUE HttpParser_buf(VALUE self)
{
  return data_get(self)->buf;
}

static VALUE HttpParser_env(VALUE self)
{
  return data_get(self)->env;
}

/**
 * call-seq:
 *    parser.filter_body(dst, src) => nil/src
 *
 * Takes a String of +src+, will modify data if dechunking is done.
 * Returns +nil+ if there is more data left to process.  Returns
 * +src+ if body processing is complete. When returning +src+,
 * it may modify +src+ so the start of the string points to where
 * the body ended so that trailer processing can begin.
 *
 * Raises HttpParserError if there are dechunking errors.
 * Basically this is a glorified memcpy(3) that copies +src+
 * into +buf+ while filtering it through the dechunker.
 */
static VALUE HttpParser_filter_body(VALUE self, VALUE dst, VALUE src)
{
  struct http_parser *hp = data_get(self);
  char *srcptr;
  long srclen;

  srcptr = RSTRING_PTR(src);
  srclen = RSTRING_LEN(src);

  StringValue(dst);

  if (HP_FL_TEST(hp, CHUNKED)) {
    if (!chunked_eof(hp)) {
      rb_str_modify(dst);
      rb_str_resize(dst, srclen); /* we can never copy more than srclen bytes */

      hp->s.dest_offset = 0;
      hp->cont = dst;
      hp->buf = src;
      http_parser_execute(hp, srcptr, srclen);
      if (hp->cs == http_parser_error)
        parser_raise(eHttpParserError, "Invalid HTTP format, parsing fails.");

      assert(hp->s.dest_offset <= hp->offset &&
             "destination buffer overflow");
      advance_str(src, hp->offset);
      rb_str_set_len(dst, hp->s.dest_offset);

      if (RSTRING_LEN(dst) == 0 && chunked_eof(hp)) {
        assert(hp->len.chunk == 0 && "chunk at EOF but more to parse");
      } else {
        src = Qnil;
      }
    }
  } else {
    /* no need to enter the Ragel machine for unchunked transfers */
    assert(hp->len.content >= 0 && "negative Content-Length");
    if (hp->len.content > 0) {
      long nr = MIN(srclen, hp->len.content);

      rb_str_modify(dst);
      rb_str_resize(dst, nr);
      /*
       * using rb_str_replace() to avoid memcpy() doesn't help in
       * most cases because a GC-aware programmer will pass an explicit
       * buffer to env["rack.input"].read and reuse the buffer in a loop.
       * This causes copy-on-write behavior to be triggered anyways
       * when the +src+ buffer is modified (when reading off the socket).
       */
      hp->buf = src;
      memcpy(RSTRING_PTR(dst), srcptr, nr);
      hp->len.content -= nr;
      if (hp->len.content == 0) {
        HP_FL_SET(hp, REQEOF);
        hp->cs = http_parser_first_final;
      }
      advance_str(src, nr);
      src = Qnil;
    }
  }
  hp->offset = 0; /* for trailer parsing */
  return src;
}

#define SET_GLOBAL(var,str) do { \
  var = find_common_field(str, sizeof(str) - 1); \
  assert(!NIL_P(var) && "missed global field"); \
} while (0)

void Init_unicorn_http(void)
{
  VALUE mUnicorn, cHttpParser;

  mUnicorn = rb_const_get(rb_cObject, rb_intern("Unicorn"));
  cHttpParser = rb_define_class_under(mUnicorn, "HttpParser", rb_cObject);
  eHttpParserError =
         rb_define_class_under(mUnicorn, "HttpParserError", rb_eIOError);
  e413 = rb_define_class_under(mUnicorn, "RequestEntityTooLargeError",
                               eHttpParserError);
  e414 = rb_define_class_under(mUnicorn, "RequestURITooLongError",
                               eHttpParserError);

  init_globals();
  rb_define_alloc_func(cHttpParser, HttpParser_alloc);
  rb_define_method(cHttpParser, "initialize", HttpParser_init, 0);
  rb_define_method(cHttpParser, "clear", HttpParser_clear, 0);
  rb_define_method(cHttpParser, "reset", HttpParser_reset, 0);
  rb_define_method(cHttpParser, "dechunk!", HttpParser_dechunk_bang, 0);
  rb_define_method(cHttpParser, "parse", HttpParser_parse, 0);
  rb_define_method(cHttpParser, "add_parse", HttpParser_add_parse, 1);
  rb_define_method(cHttpParser, "headers", HttpParser_headers, 2);
  rb_define_method(cHttpParser, "trailers", HttpParser_headers, 2);
  rb_define_method(cHttpParser, "filter_body", HttpParser_filter_body, 2);
  rb_define_method(cHttpParser, "content_length", HttpParser_content_length, 0);
  rb_define_method(cHttpParser, "body_eof?", HttpParser_body_eof, 0);
  rb_define_method(cHttpParser, "keepalive?", HttpParser_keepalive, 0);
  rb_define_method(cHttpParser, "headers?", HttpParser_has_headers, 0);
  rb_define_method(cHttpParser, "next?", HttpParser_next, 0);
  rb_define_method(cHttpParser, "buf", HttpParser_buf, 0);
  rb_define_method(cHttpParser, "env", HttpParser_env, 0);

  /*
   * The maximum size a single chunk when using chunked transfer encoding.
   * This is only a theoretical maximum used to detect errors in clients,
   * it is highly unlikely to encounter clients that send more than
   * several kilobytes at once.
   */
  rb_define_const(cHttpParser, "CHUNK_MAX", OFFT2NUM(UH_OFF_T_MAX));

  /*
   * The maximum size of the body as specified by Content-Length.
   * This is only a theoretical maximum, the actual limit is subject
   * to the limits of the file system used for +Dir.tmpdir+.
   */
  rb_define_const(cHttpParser, "LENGTH_MAX", OFFT2NUM(UH_OFF_T_MAX));

  /* default value for keepalive_requests */
  rb_define_const(cHttpParser, "KEEPALIVE_REQUESTS_DEFAULT",
                  ULONG2NUM(keepalive_requests));

  rb_define_singleton_method(cHttpParser, "keepalive_requests", ka_req, 0);
  rb_define_singleton_method(cHttpParser, "keepalive_requests=", set_ka_req, 1);
  rb_define_singleton_method(cHttpParser, "trust_x_forwarded=", set_xftrust, 1);
  rb_define_singleton_method(cHttpParser, "trust_x_forwarded?", xftrust, 0);
  rb_define_singleton_method(cHttpParser, "max_header_len=", set_maxhdrlen, 1);

  init_common_fields();
  SET_GLOBAL(g_http_host, "HOST");
  SET_GLOBAL(g_http_trailer, "TRAILER");
  SET_GLOBAL(g_http_transfer_encoding, "TRANSFER_ENCODING");
  SET_GLOBAL(g_content_length, "CONTENT_LENGTH");
  SET_GLOBAL(g_http_connection, "CONNECTION");
  id_clear = rb_intern("clear");
  id_set_backtrace = rb_intern("set_backtrace");
  init_unicorn_httpdate();
}
#undef SET_GLOBAL
