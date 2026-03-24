#!/bin/bash -x

git send-email \
	--suppress-cc=all \
	--to "cip-dev@lists.cip-project.org" \
	--to "Nobuhiro Iwamatsu <nobuhiro1.iwamatsu@toshiba.co.jp>" \
	--to "Pavel Machek <pavel@denx.de>" \
	--cc "Biju Das <biju.das@bp.renesas.com>" \
	--cc "Lad Prabhakar <prabhakar.mahadev-lad.rj@bp.renesas.com>" \
	--cc "Fabrizio Castro <fabrizio.castro.jz@renesas.com>" \
	*.patch
