.name "command"
.comment "school21"

	sti r1, %:live, %1
	live %0

first:
	fork %:second
	fork %:fourth
	ldi %:live, %0, r2
	ld %0, r3
	ld %0, r4
	zjmp %:live

second:
	fork %:third
	ldi %:live, %4, r2
	ld %4, r3
	ld %0, r4
	zjmp %:live

third:
	ldi %:live, %8, r2
	ld %8, r3
	ld %0, r4
	zjmp %:live

fourth:
	ldi %:live, %0, r2
	ld %12, r3
	ld %0, r4
	zjmp %:live

live:
	live %0
	sti r2, %:end, r3
end:
