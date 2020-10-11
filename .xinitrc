bg=grey19
fg=grey70
fa='Source Code Pro'
fs=10

# Launch xterm with my favourite colour scheme and ask user for start up scripts
# if they dont exist then run them and exit to bash if anything goes wrong or
# user exits program, instead of closing client.
xterm -bg "$bg" -fg "$fg" -fa "$fa" -fs "$fs" -bc -maximize -e ~/.matapihi_run
xterm -bg "$bg" -fg "$fg" -fa "$fa" -fs "$fs" -bc -maximize &

