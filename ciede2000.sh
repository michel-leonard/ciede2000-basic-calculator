#!/bin/sh

# This script written in Bash/Dash is released into the public domain.
# Goal: Display the CIEDE2000s while reading a CSV containing the L*a*b* colors.
# Precision: Arbitrary using BC (Basic Calculator), default to 20 decimal digits.
# Author: Michel LEONARD in 2026.

# Stops everything in case of error.
set -e

# Uses POSIX minimal english.
export LC_ALL=C BC_LINE_LENGTH=0

# Displays help if requested.
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "Usage: $0 [-p precision] [-c|--canonical]"
	echo "  -c, --canonical    Use the canonical CIEDE2000 formula"
	echo "  -q, --quiet        Does not display details of multicore processing"
	echo "  -p, --precision    Number of correct decimal places (default: 20, min:0, max:320)"
	echo ""
	echo "Provide on standard input a CSV file where each line contains either:"
	echo ""
	echo "  - 6 columns:  L1,a1,b1,L2,a2,b2"
	echo "  - 9 columns:  L1,a1,b1,L2,a2,b2,kL,kC,kH"
	echo ""
	echo "The script computes the CIEDE2000 color difference and appends it as a new column."
	echo ""
	echo "Example CSV input:"
	echo "95.3,58.8,2.1,95.7,61.9,-1.7"
	echo "78.7,65.2,-2.9,77.5,60.7,2.8"
	echo ""
	echo "Corresponding CSV output:"
	echo "95.3,58.8,2.1,95.7,61.9,-1.7,1.940859230419438209070"
	echo "78.7,65.2,-2.9,77.5,60.7,2.8,2.919895295671140878217"
	exit 0
fi

# Check if gawk or awk is installed.
if command -v gawk > /dev/null 2>&1; then
	awk="$(command -v gawk)"
elif command -v awk > /dev/null 2>&1; then
	awk="$(command -v awk)"
else
	echo "Error: awk is not installed." >&2
	exit 1
fi

# Checks the availability of all other functions in use.
for cmd in bc cd cat dirname mktemp paste pwd split trap rm; do
	command -v "$cmd" > /dev/null 2>&1 || {
		echo "Error: required command '$cmd' not found." >&2
		exit 1
	}
done

# Put the directory where the script resides in a variable.
origin_dir="$(cd "$(dirname "$0")" && pwd)"

# Checks if the ciede2000.bc script is available in this directory.
if [ ! -r "$origin_dir/ciede2000.bc" ]; then
	echo "Error: cannot read ciede2000.bc" >&2
	exit 1
fi

# The default parameters for the ciede2000 function are set.
canonical=0
quiet=0
precision=20

# Reads the parameters passed by the user on the command line.
while [ $# -gt 0 ]; do
	case "$1" in
		-c|--canonical) canonical=1; shift ;;
		-q|--quiet) quiet=1; shift ;;
		-p|--precision) { [ $# -gt 1 ] && [ "$(( $2 ))" = "$2" ] && precision="$(( $2 ))" && shift 2; } || shift ;;
		*) echo "Unknown option: $1" >&2; exit 1 ;;
	esac
done

# We make sure the parameters are reasonable.
if [ "$precision" -lt 0 ]; then
	precision=0
elif [ 320 -lt "$precision" ]; then
	precision=320
fi

# Prepares to work in a temporary directory.
dir="$(mktemp -d)"
trap 'rm -rf "$dir"' EXIT INT TERM HUP
cd "$dir" || exit 1

# Stores the complete standard input (stdin) in a file.
cat > raw-input.csv

n_lines="$("$awk" 'END{print NR}' raw-input.csv)"

if [ "$n_lines" -eq 0 ]; then
	[ "$quiet" -eq 0 ] && echo "Error: no data on the standard input for CIEDE2000." >&2
	exit 0
fi

# Determines the number of processing units available for parallelization.
if command -v nproc > /dev/null 2>&1; then
	n_cpu="$(nproc)"
else
	n_cpu="$(getconf _NPROCESSORS_ONLN 2> /dev/null || echo 1)"
fi

# Splits the standard input according to the number of processing units.
if [ 1 -lt "$n_cpu" ]; then
	n_lines="$(( (n_lines + n_cpu - 1) / n_cpu ))"
	split -l "$n_lines" - < raw-input.csv
	rm raw-input.csv
else
	mv raw-input.csv xaa
fi

# Presents the files prepared for each CIEDE2000 processing unit.
if [ "$quiet" -eq 0 ]; then
	i=0
	for file in x*; do
		i="$(( 1 + i ))"
		size="$(wc -c < "$file" 2> /dev/null || echo 0)"
		if [ "$(( size >> 10 ))" -eq 0 ]; then
			size="$size B"
		elif [ "$(( size >> 20 ))" -eq 0 ]; then
			size="$(( size >> 10 )) KB"
		else
			size="$(( size >> 20 )) MB"
		fi
		first_line="$("$awk" 'NR==1{print; exit}' "$file")"
		echo "task-for-cpu-$i.csv ($size) contains L*a*b* color pairs, first line: $first_line" >&2
	done
fi

# Calculates the scale for BC so that the requested precision matches the number of correct decimal places.
[ "$precision" -lt 20 ] && bc_scale=20 || bc_scale="$precision"
bc_scale="$(( 7 * bc_scale / 4 ))"

# Records the start date of the job.
[ "$quiet" -eq 0 ] && t_1="$(date +%s 2>/dev/null || echo 0)"

# Processes all files in parallel, with AWK writing the appropriate lines to the BC standard input.
for file in x*; do
	"$awk" -F ',' "
	BEGIN {
		print \"scale=$precision\";
		while (0 < (getline line < \"$origin_dir/ciede2000.bc\"))
			print line;
	} {
		gsub(/[eE]/, \"*10^\", \$0);
		if (NF == 6 && \$0 !~ /[a-zA-Z]/)
			# Sets the parametric factors kL, kC, and kH to 1.0 if they are not present in the CSV.
			printf(\"ciede2000(%s,1,1,1,$canonical)\\n\", \$0);
		else if (NF == 9 && \$0 !~ /[a-zA-Z]/)
			printf(\"ciede2000(%s,$canonical)\\n\", \$0);
		else {
			++ignored;
			print(-1);
		}
	} END {
		print(NR-ignored) > \"count-$file\"
	}" "$file" | bc -ql | paste -d ',' "$file" - > solved-"$file" &
done
wait

# Displays job execution time.
if [ "$quiet" -eq 0 ]; then
	t_2="$(date +%s 2>/dev/null || echo 0)"
	if [ "$t_1" != "$t_2" ]; then
		h=0
		m=0
		s="$(( t_2 - t_1 ))"
		if [ 3599 -lt "$s" ]; then
			h="$(( s / 3600 ))"
			s="$(( s - 3600 * h ))"
		fi
		if [ 59 -lt "$s" ]; then
			m="$(( s / 60 ))"
			s="$(( s - 60 * m ))"
		fi
		n_lines="$("$awk" "{ count+=\$0 } END { print count }" count*)"
		printf 'It took %02d:%02d:%02d to achieve %d correct' "$h" "$m" "$s" "$precision" >&2
		printf ' decimal places on the %d CIEDE2000 calculations.\n\n' "$n_lines" >&2
	fi
fi

# Delete any temporary files that are not needed to display the results.
rm count* x*

# Displays results, with the number of correct decimal places requested by the user.
"$awk" '{
	if (!sub(/,-1$/, ""))
		sub(/,\./, ",0.");
	print;
}' solved-*
