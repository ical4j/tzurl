"""
A parser for date-time values/rules from the IANA time-zone database (tzdb) data.
"""
from datetime import datetime


dtformats = [
    '%Y %b %d %H:%M:%S',
    '%Y %b %d %H:%M',
    '%Y %b %d %H:%Mu',
    '%Y %b %d %H:%Ms',
    '%Y %b %a>=%d %H:%M:%S',
    '%Y %b last%a %H:%M:%S',
    '%Y %b last%a %H:%M',
    '%Y %b %d',
    '%Y %b',
    '%Y'
]


def parse_datetime(dtstring, formats=dtformats):
    if len(dtstring) > 0:
        ex = None
        for dtformat in formats:
            try:
                return datetime.strptime(dtstring, dtformat)
            except ValueError as e:
                print(f'Format not matched: {e}')
                ex = e
        raise ex
    return datetime.now()
