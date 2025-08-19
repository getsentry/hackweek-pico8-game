// Q is now also X
document.addEventListener("keydown", (e) => {
  if (event.keyCode == 81) {
    pico8_buttons[0] |= 0x10;
  }
});

document.addEventListener("keyup", (e) => {
  if (event.keyCode == 81) {
    pico8_buttons[0] &= ~0x10;
  }
});
