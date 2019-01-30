#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

101coinD=${101coinD:-$BINDIR/101coind}
101coinCLI=${101coinCLI:-$BINDIR/101coin-cli}
101coinTX=${101coinTX:-$BINDIR/101coin-tx}
101coinQT=${101coinQT:-$BINDIR/qt/101coin-qt}

[ ! -x $101coinD ] && echo "$101coinD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BTCVER=($($101coinCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for 101coind if --version-string is not set,
# but has different outcomes for bitcoin-qt and 101coin-cli.
echo "[COPYRIGHT]" > footer.h2m
$101coinD --version | sed -n '1!p' >> footer.h2m

for cmd in $101coinD $101coinCLI $101coinTX $101coinQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
