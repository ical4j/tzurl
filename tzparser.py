#!/usr/bin/env python3

"""
A parser for IANA time-zone database (tzdb) data.

Usage: tzparser [-o <output_format>] <source_directory>

e.g.

* tzparser -o rfc5545 tzdata2018e
"""
import argparse
import json
import re

import dtparser


def parse_rules(filename):
    rules = {}
    with open(filename) as fin:
        for line in fin:
            if not line.strip().startswith('#') and len(line.strip()) > 0:
                rule = line.strip().split()
                if rule[0] == 'Rule':
                    name = rule[1]
                    date = ' '.join([rule[2], rule[5], rule[6], rule[7]]).replace('24:00', '23:59:59')
                    offsets = rules[name] if name in rules else []
                    offset = next((o for o in offsets if o['offset'] == rule[8]), None)
                    if rule[3] == 'only':
                        if offset:
                            offset['dates'].append(date)
                        else:
                            offsets.append({
                                'offset': rule[8],
                                'letter': rule[9].replace('-', ''),
                                'datest': date,
                                'dates': [date],
                            })
                    if offsets and name not in rules:
                        rules[name] = offsets
    return rules


def parse_zones(filename):
    zones = {}
    with open(filename) as fin:
        zone_name = None
        for line in fin:
            if not line.strip().startswith('#') and len(line.strip()) > 0:
                zone = line.strip().split('#')[0].split()
                if zone[0] == 'Zone':
                    zone_name = zone[1]
                    offset = zone[2]
                    rules = zone[3]
                    abbrev = zone[4]
                    until = zone[5:] if len(zone) > 5 else None
                    if zone_name in zones:
                        zones[zone_name].append({
                            'offset': offset,
                            'rules': rules,
                            'abbrev': abbrev,
                            'until': until,
                        })
                    else:
                        zones[zone_name] = [{
                            'offset': offset,
                            'rules': rules,
                            'abbrev': abbrev,
                            'until': until,
                        }]
                elif line.startswith('\t') and zone_name is not None:
                    offset = zone[0]
                    rules = zone[1]
                    abbrev = zone[2]
                    until = zone[3:] if len(zone) > 3 else None
                    if zone_name in zones:
                        zones[zone_name].append({
                            'offset': offset,
                            'rules': rules,
                            'abbrev': abbrev,
                            'until': until,
                        })
                    else:
                        zones[zone_name] = [{
                            'offset': offset,
                            'rules': rules,
                            'abbrev': abbrev,
                            'until': until,
                        }]

    return zones


def parse_aliases(filename):
    aliases = {}
    return aliases


def output(zones, rules, format):
    if format == 'json':
        print(json.dumps(zones, indent=2))
    elif format == 'rfc5545':
        for tzname, observances in zones.items():
            print(f'''BEGIN:VTIMEZONE\r
TZID:{tzname}\r
TZURL:http://tzurl.org/zoneinfo/{tzname}\r
X-LIC-LOCATION:{tzname}\r
{rfc5545_observances(observances, rules)}
END:VTIMEZONE\r\n''')


def rfc5545_rules(startdt, rdates):
    result = []
    if rdates is not None:
        for rule in rdates:
            result.append(f"RDATE:{rule.strftime('%Y%m%dT%H%M%S')}")
    else:
        result.append(f"RDATE:{startdt.strftime('%Y%m%dT%H%M%S')}")

    return '\r\n'.join(result)


def rfc5545_observances(observances, rules):
    result = []
    prev_observance = None
    for observance in observances:
        if prev_observance is not None:
            if observance['rules'] in rules:
                for rule in rules[observance['rules']]:
                    type = 'STANDARD' if rule['offset'] == '0' else 'DAYLIGHT'
                    # rdate = ' '.join([rule['years'][0], rule['month'], rule['date'], rule['time']])
                    result.append(rfc5545_observance(type, prev_observance['offset'],
                                                     observance['offset'],
                                                     observance['abbrev'].replace('%s', rule['letter']),
                                                     rule['datest'], rule['dates']))
            else:
                result.append(rfc5545_observance('STANDARD', prev_observance['offset'],
                                                 observance['offset'], observance['abbrev'],
                                                 ' '.join(prev_observance['until'])))
        prev_observance = observance

    return ''.join(result)


def rfc5545_observance(type, offsetfrom, offsetto, abbrev, start, rdates=None):
    startdt = dtparser.parse_datetime(start)
    recurdts = (dtparser.parse_datetime(rdate) for rdate in rdates) if rdates else None
    offset_pattern = re.compile(r'(?<=[-+]).*')
    if not offset_pattern.search(offsetfrom):
        offsetfrom = '+' + offsetfrom

    if not offset_pattern.search(offsetto):
        offsetto = '+' + offsetto

    padoffsetfrom = ''.join([offsetfrom.split(':')[0].zfill(3)] + offsetfrom.split(':')[1:])
    padoffsetto = ''.join([offsetto.split(':')[0].zfill(3)] + offsetto.split(':')[1:])

    return f'''BEGIN:{type}\r
TZOFFSETFROM:{dtparser.parse_datetime(padoffsetfrom, ['%z']).strftime('%z')}\r
TZOFFSETTO:{dtparser.parse_datetime(padoffsetto, ['%z']).strftime('%z')}\r
TZNAME:{abbrev}\r
DTSTART:{startdt.strftime('%Y%m%dT%H%M%S')}\r
{rfc5545_rules(startdt, recurdts)}
END:{type}\r\n'''


parser = argparse.ArgumentParser(description='IANA time-zones (tzdb) parser.')
parser.add_argument('-o', '--output', metavar='<output_format>', choices=['json', 'rfc5545'], nargs='?',
                    default='json', help='output format')
parser.add_argument('source', metavar='<filename>', help='tzdata compatibility file', default='backwards')

args = parser.parse_args()

output(parse_zones(args.source), parse_rules(args.source), args.output)
