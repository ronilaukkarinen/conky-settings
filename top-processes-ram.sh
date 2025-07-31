#!/bin/bash
ps aux | awk '
    NR==1 {next} # Skip header
    {
        process_name = $11;
        # Extract just the executable name from the path
        sub(/.*\//, "", process_name);
        total_ram[process_name] += $6; # Sum RAM (in KB) for each process name
    }
    END {
        # After processing all lines, print the aggregated RAM and process name
        for (p in total_ram) {
            print total_ram[p], p;
        }
    }
' | sort -nr | head -n 10 | awk '
    {
        # Format the final output
        printf "%d. %s, %.2fMB\n", NR, $2, $1 / 1024;
    }
'
