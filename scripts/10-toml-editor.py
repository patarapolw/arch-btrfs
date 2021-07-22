#!/usr/bin/env python3

import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--set', '-s', help='K=V', required=True)
parser.add_argument('--header', '-H', help='Enclosed in [*]', required=True)
parser.add_argument('filename', nargs=1)

args = parser.parse_args()

is_subsegment = False

k, v = args.set.split('=')

with open(args.filename, 'r') as f:
    for line in f.read().splitlines(keepends=True):
        if line.startswith('['):
            is_subsegment = line.rstrip() == args.header

        if is_subsegment:
            if line.startswith(k):
                sys.stdout.write(args.set)
                sys.stdout.write('\n')
                continue

        sys.stdout.write(line)
