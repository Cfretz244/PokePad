entry:
ld bc, 0168                 ; Number of bytes to write, 320.
ld hl, C3A0                 ; Address to write to (Screen I/O)
ld a, 10                    ; Tile identifier to write (Black tile).
call 36E0                   ; Call memset.
ld hl, D53A                 ; Load address of cursor x position.
ldi (hl), 10                ; Set x position to 10 and increment the pointer.
ld (hl), 9                  ; Set y position to 9.
halt

entry_loop:
ld hl, FFF8                 ; Load address of hardward input byte.
ld e, (hl)                  ; Load input.
ld a, F0                    ; Setup bit mask for directional pad.
and e                       ; Perform comparison.
jr nz, direction_pressed    ; Jump out if a direction was pressed.
jr entry_loop               ; No direction was pressed. Check again.

direction_pressed:
ld hl, D53A                 ; Load address of cursor X position.
ldi b, (hl)                 ; Load cursor X position and increment pointer.
ld c, (hl)                  ; Load cursor Y position.
ld hl, C3A0                 ; Load base address for screen I/O.
call resolve                ; Resolve where to write on the screen.
call paint                  ; Paint the appropriate tile appropriately.
call update                 ; Update the cursor position.
jr entry_loop               ; Restart.

resolve:
xor a                       ; Reset A to zero.
cp b                        ; Compare B with a.
jr z, resolve_x             ; B has been reduced to zero. Row has been identified.
add hl, 14                  ; B still has a positive value. Jump forward another row.
dec b                       ; Decrease B by one.
jr resolve                  ; Run again.
resolve_x:
add hl, c                   ; Add the X coordinate to get the proper tile.
ret

paint:
ld a, 01                    ; Load the bitmask for the A button.
and e                       ; Check if the A button was pressed.
jr z, lighten               ; Button was pressed, paint a white tile.
ld a, 02                    ; Load the bitmask for the B button.
and e                       ; Check if the B button was pressed.
jr z, darken                ; Button was pressed, paint a black tile.
ret
lighten:
ld b, 00                    ; Load identifier for a white tile.
jr draw
darken:
ld b, 10                    ; Load identifier for a black tile.
draw:
ld (hl), b                  ; Draw the tile.
ret

update:
ld hl, D53A                 ; Load the address for the cursor X position.
ld a, 10                    ; Load bitmask for right movement.
and e                       ; Compare.
jr nz, move_right           ; Move the cursor right.
ld a, 20                    ; Load bitmask for left movement.
and e                       ; Compare.
jr nz, move_left            ; Move the cursor left.
ld a, 40                    ; Load bitmask for upward movement.
and e                       ; Compare
jr nz, move_up              ; Move the cursor up.
jr move_down                ; No other options, move the cursor down.
move_right:
inc (hl)                    ; Update cursor position.
ret
move_left:
dec (hl)                    ; Update cursor position.
ret
move_up:
inc hl
inc (hl)                    ; Update cursor position.
ret
move_down:
inc hl
dec (hl)                    ; Update cursor position.
ret
