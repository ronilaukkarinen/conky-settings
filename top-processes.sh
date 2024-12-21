#!/bin/bash
ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head -n 51
