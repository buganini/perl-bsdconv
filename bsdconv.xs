/*
 * Copyright (c) 2009-2013 Kuan-Chung Chiu <buganini@gmail.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#include <bsdconv.h>

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include <errno.h>
#include <stdio.h>
#include <string.h>

#ifndef WIN32
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

typedef struct bsdconv_instance * Bsdconv;
typedef FILE * Bsdconv_file;

#define IBUFLEN 1024
#define TEMPLATE "bsdconv(\"%s\")"

MODULE = bsdconv		PACKAGE = bsdconv

BOOT:
{
	HV *m;

	m = gv_stashpv("bsdconv", TRUE);
	newCONSTSUB(m, "FROM", newSViv(FROM));
	newCONSTSUB(m, "INTER", newSViv(INTER));
	newCONSTSUB(m, "TO", newSViv(TO));

	newCONSTSUB(m, "CTL_ATTACH_SCORE", newSViv(BSDCONV_ATTACH_SCORE));
	newCONSTSUB(m, "CTL_SET_WIDE_AMBI", newSViv(BSDCONV_SET_WIDE_AMBI));
	newCONSTSUB(m, "CTL_SET_TRIM_WIDTH", newSViv(BSDCONV_SET_TRIM_WIDTH));
	newCONSTSUB(m, "CTL_ATTACH_OUTPUT_FILE", newSViv(BSDCONV_ATTACH_OUTPUT_FILE));
}

SV*
insert_phase(conversion, codecs, phase_type, ophasen)
	char* conversion
	char* codecs
	int phase_type
	int ophasen
	PREINIT:
		char *s;
	CODE:
		s=bsdconv_insert_phase(conversion, codecs, phase_type, ophasen);
		RETVAL=newSVpv(s, 0);
		bsdconv_free(s);
	OUTPUT:
		RETVAL

SV*
insert_codec(conversion, codec, ophasen, ocodecn)
	char* conversion
	char* codec
	int ophasen
	int ocodecn
	PREINIT:
		char *s;
	CODE:
		s=bsdconv_insert_codec(conversion, codec, ophasen, ocodecn);
		RETVAL=newSVpv(s, 0);
		bsdconv_free(s);
	OUTPUT:
		RETVAL

SV*
replace_phase(conversion, codecs, phase_type, ophasen)
	char* conversion
	char* codecs
	int phase_type
	int ophasen
	PREINIT:
		char *s;
	CODE:
		s=bsdconv_replace_phase(conversion, codecs, phase_type, ophasen);
		RETVAL=newSVpv(s, 0);
		bsdconv_free(s);
	OUTPUT:
		RETVAL

SV*
replace_codec(conversion, codec, ophasen, ocodecn)
	char* conversion
	char* codec
	int ophasen
	int ocodecn
	PREINIT:
		char *s;
	CODE:
		s=bsdconv_replace_codec(conversion, codec, ophasen, ocodecn);
		RETVAL=newSVpv(s, 0);
		bsdconv_free(s);
	OUTPUT:
		RETVAL


SV*
error()
	PREINIT:
		char *s;
	CODE:
		s=bsdconv_error();
		RETVAL=newSVpv(s, 0);
		bsdconv_free(s);
	OUTPUT:
		RETVAL

SV*
codec_check(phase_type, codec)
	int phase_type
	char *codec
	CODE:
		if(bsdconv_codec_check(phase_type, codec))
			XSRETURN_YES;
		XSRETURN_NO;
	OUTPUT:
		RETVAL

AV*
codecs_list(phase_type)
	int phase_type
	PREINIT:
		char **list;
		char **p;
	CODE:
		RETVAL=newAV();
		list=bsdconv_codecs_list(phase_type);
		p=list;
		while(*p!=NULL){
			av_push(RETVAL, newSVpv(*p, 0));
			bsdconv_free(*p);
			p+=1;
		}
		bsdconv_free(list);
	OUTPUT:
		RETVAL

AV*
mktemp(template)
	char *template
	CODE:
		char *fn=strdup(template);
		int fd=bsdconv_mkstemp(fn);
		if(fd==-1)
			XSRETURN_UNDEF;
		FILE *fp=fdopen(fd, "wb+");
		SV *bsdconv_file=sv_newmortal();
		sv_setref_pv(bsdconv_file,"Bsdconv_file",(void *) fp);
		RETVAL=newAV();
		av_push(RETVAL, newSVsv(bsdconv_file));
		av_push(RETVAL, newSVpv(fn, 0));
	OUTPUT:
		RETVAL

Bsdconv_file
fopen(filename, mode)
	char *filename
	char *mode
	CODE:
		RETVAL=fopen(filename, mode);
	OUTPUT:
		RETVAL

Bsdconv
new(package, conversion)
	char *package
	char *conversion
	CODE:
		RETVAL=bsdconv_create(conversion);
	OUTPUT:
		RETVAL

MODULE = bsdconv		PACKAGE = Bsdconv

void
DESTROY(ins)
	Bsdconv ins
	CODE:
		bsdconv_destroy(ins);

SV*
toString(ins)
	Bsdconv ins
	PREINIT:
		char *s;
		char *s2;
		int len;
	CODE:
		len=sizeof(TEMPLATE);
		s=bsdconv_pack(ins);
		len+=strlen(s);
		s2=malloc(len);
		sprintf(s2, TEMPLATE, s);
		bsdconv_free(s);
		RETVAL=newSVpv(s2, 0);
		free(s2);
	OUTPUT:
		RETVAL

void
init(ins)
	Bsdconv ins
	CODE:
		bsdconv_init(ins);

void
ctl(ins, ctl, res, num)
	Bsdconv ins
	int ctl
	SV* res
	int num
	CODE:
		void *ptr=NULL;
		if(sv_derived_from(res,"Bsdconv_file")){
			IV tmp = SvIV((SV*)SvRV(res));
			ptr=(void *)tmp;
		}
		bsdconv_ctl(ins, ctl, ptr, num);

SV*
conv_chunk(ins, str)
	Bsdconv ins
	SV* str
	PREINIT:
		char *s;
		SSize_t l;
	CODE:
		s=SvPV(str, l);

		ins->output_mode=BSDCONV_AUTOMALLOC;
		ins->input.data=s;
		ins->input.len=l;
		ins->input.flags=0;
		ins->input.next=NULL;
		bsdconv(ins);

		RETVAL=newSVpvn(ins->output.data, (STRLEN)ins->output.len);
		bsdconv_free(ins->output.data);
	OUTPUT:
		RETVAL

SV*
conv_chunk_last(ins, str)
	Bsdconv ins
	SV* str
	PREINIT:
		char *s;
		SSize_t l;
	CODE:
		s=SvPV(str, l);

		ins->output_mode=BSDCONV_AUTOMALLOC;
		ins->input.data=s;
		ins->input.len=l;
		ins->input.flags=0;
		ins->input.next=NULL;
		ins->flush=1;
		bsdconv(ins);

		RETVAL=newSVpvn(ins->output.data, (STRLEN)ins->output.len);
		bsdconv_free(ins->output.data);
	OUTPUT:
		RETVAL

SV*
conv(ins, str)
	Bsdconv ins
	SV* str
	PREINIT:
		char *s;
		SSize_t l;
	CODE:
		s=SvPV(str, l);

		bsdconv_init(ins);
		ins->output_mode=BSDCONV_AUTOMALLOC;
		ins->input.data=s;
		ins->input.len=l;
		ins->input.flags=0;
		ins->input.next=NULL;
		ins->flush=1;
		bsdconv(ins);

		RETVAL=newSVpvn(ins->output.data, (STRLEN)ins->output.len);
		bsdconv_free(ins->output.data);
	OUTPUT:
		RETVAL

SV*
conv_file(ins, f1, f2)
	Bsdconv ins
	SV* f1
	SV* f2
	PREINIT:
		char *s1, *s2;
		SSize_t l;
		FILE *inf, *otf;
		char *in;
		char *tmp;
		int fd;
	CODE:
		s1=SvPV(f1, l);
		s2=SvPV(f2, l);
		inf=fopen(s1,"r");
		if(!inf) XSRETURN_UNDEF;
		tmp=malloc(l+8);
		strcpy(tmp, s2);
		strcat(tmp, ".XXXXXX");
		if((fd=mkstemp(tmp))==-1){
			free(tmp);
			XSRETURN_UNDEF;
		}
		otf=fdopen(fd,"w");
		if(!otf){
			free(tmp);
			XSRETURN_UNDEF;
		}
#ifndef WIN32
		struct stat stat;
		fstat(fileno(inf), &stat);
		fchown(fileno(otf), stat.st_uid, stat.st_gid);
		fchmod(fileno(otf), stat.st_mode);
#endif
		bsdconv_init(ins);
		do{
			in=bsdconv_malloc(IBUFLEN);
			ins->input.data=in;
			ins->input.len=fread(in, 1, IBUFLEN, inf);
			ins->input.flags|=F_FREE;
			ins->input.next=NULL;
			if(ins->input.len==0){
				ins->flush=1;
			}
			ins->output_mode=BSDCONV_FILE;
			ins->output.data=otf;
			bsdconv(ins);
		}while(ins->flush==0);

		fclose(inf);
		fclose(otf);
		unlink(s2);
		rename(tmp,s2);
		free(tmp);
		XSRETURN_YES;
	OUTPUT:
		RETVAL

void
counter(ins, ...)
	Bsdconv ins
	PREINIT:
		char *key;
		HV *hash;
		struct bsdconv_counter_entry *p;
		bsdconv_counter_t *v;
	PPCODE:
		if(items > 1){
			key=(char *)SvPV_nolen(ST(1));
			v=bsdconv_counter(ins, key);
			PUSHs(sv_2mortal(newSViv(*v)));
		}else{
			hash=(HV *)sv_2mortal((SV *)newHV());
			p=ins->counter;
			while(p){
				hv_store(hash, p->key, strlen(p->key), newSVuv(p->val), 0);
				p=p->next;
			}
			EXTEND(SP, 1);
			PUSHs(newRV_noinc((SV *)hash));
		}

void
counter_reset(ins, ...)
	Bsdconv ins
	PREINIT:
		char *key;
	PPCODE:
		if(items > 1){
			key=(char *)SvPV_nolen(ST(1));
			bsdconv_counter_reset(ins, key);
		}else{
			bsdconv_counter_reset(ins, NULL);
		}

MODULE = bsdconv		PACKAGE = Bsdconv_file

void
DESTROY(fp)
	Bsdconv_file fp
	CODE:
		fclose(fp);
