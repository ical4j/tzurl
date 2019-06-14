#!/usr/bin/env python3

"""
A parser for IANA time-zone database (tzdb) backward compatibility data.

Usage: tzalias [-o <output_format>] <source_directory>

e.g.

* tzalias -o nginx tzdata2018e
"""
import argparse
import json


def parse_file(filename):
    aliases = {}
    with open(filename) as fin:
        for line in fin:
            if not line.strip().startswith('#') and len(line.strip()) > 0:
                alias = line.strip().split()
                if alias[0] == 'Link':
                    if alias[1] in aliases:
                        aliases[alias[1]].append(alias[2])
                    else:
                        aliases[alias[1]] = [alias[2]]

    return aliases


def output(dict, format):
    if format == 'json':
        print(json.dumps(dict, indent=2))
    elif format == 'nginx':
        for tzid, aliases in dict.items():
            print(f'rewrite ^(.*)({"|".join(aliases)}) $1{tzid} last;')
    elif format == 'apache':
        for tzid, aliases in dict.items():
            print(f'RewriteRule ^(.*)({"|".join(aliases)}) $1{tzid} [NC,L]')


parser = argparse.ArgumentParser(description='IANA time-zones (tzdb) aliases parser.')
parser.add_argument('-o', '--output', metavar='<output_format>', choices=['json', 'apache', 'nginx'], nargs='?',
                    default='json', help='output format')
parser.add_argument('source', metavar='<filename>', help='tzdata compatibility file', default='backwards')

args = parser.parse_args()

output(parse_file(args.source), args.output)
