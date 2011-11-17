/*
 * Copyright (c) 2009-2011 Kuan-Chung Chiu <buganini@gmail.com>
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
#include <string.h>

typedef struct bsdconv_instance * Bsdconv;

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
}

SV*
error()
	PREINIT:
		char *s;
	CODE:
		s=bsdconv_error();
		RETVAL=newSVpv(s, 0);
		free(s);
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
			free(*p);
			p+=1;
		}
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
		free(s);
		RETVAL=newSVpv(s2, 0);
		free(s2);
	OUTPUT:
		RETVAL

IV
insert_phase(ins, conversion, phase_type, ophasen)
	Bsdconv ins
	char* conversion
	int phase_type
	int ophasen
	CODE:
		RETVAL=bsdconv_insert_phase(ins, conversion, phase_type, ophasen);
	OUTPUT:
		RETVAL

IV
insert_codec(ins, conversion, ophasen, ocodecn)
	Bsdconv ins
	char* conversion
	int ophasen
	int ocodecn
	CODE:
		RETVAL=bsdconv_insert_codec(ins, conversion, ophasen, ocodecn);
	OUTPUT:
		RETVAL

IV
replace_phase(ins, conversion, phase_type, ophasen)
	Bsdconv ins
	char* conversion
	int phase_type
	int ophasen
	CODE:
		RETVAL=bsdconv_insert_phase(ins, conversion, phase_type, ophasen);
	OUTPUT:
		RETVAL

IV
replace_codec(ins, conversion, ophasen, ocodecn)
	Bsdconv ins
	char* conversion
	int ophasen
	int ocodecn
	CODE:
		RETVAL=bsdconv_insert_codec(ins, conversion, ophasen, ocodecn);
	OUTPUT:
		RETVAL

void
init(ins)
	Bsdconv ins
	CODE:
		bsdconv_init(ins);

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
		bsdconv(ins);

		RETVAL=newSVpvn(ins->output.data, (STRLEN)ins->output.len);
		free(ins->output.data);
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
		ins->flush=1;
		bsdconv(ins);

		RETVAL=newSVpvn(ins->output.data, (STRLEN)ins->output.len);
		free(ins->output.data);
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
		ins->flush=1;
		bsdconv(ins);

		RETVAL=newSVpvn(ins->output.data, (STRLEN)ins->output.len);
		free(ins->output.data);
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

		bsdconv_init(ins);
		do{
			in=malloc(IBUFLEN);
			ins->input.data=in;
			ins->input.len=fread(in, 1, IBUFLEN, inf);
			ins->input.flags|=F_FREE;
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

HV*
info(ins)
	Bsdconv ins
	CODE:
		RETVAL=newHV();
		sv_2mortal((SV*)RETVAL);
		hv_store(RETVAL, "ierr", 4, newSVuv(ins->ierr), 0);
		hv_store(RETVAL, "oerr", 4, newSVuv(ins->oerr), 0);
		hv_store(RETVAL, "score", 4, newSVuv(ins->score), 0);
	OUTPUT:
		RETVAL
