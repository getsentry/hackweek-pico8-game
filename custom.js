document.addEventListener('DOMContentLoaded', function() {
  const barbiePhoneMap = {
    "4": 0x1,
    "6": 0x2,
    "2": 0x4,
    "8": 0x8,
    "0": 0x20,  // spacebar is x
    "*": 0x10, // * is 0
  }


  // 0x1 left, 0x2 right, 0x4 up, 0x8 down, 0x10 O, 0x20 X, 0x40 menu
  if (navigator.includes("HMD Barbie Phone")) {
    document.addEventListener('keydown', function(event) {
        for (const [key, value] of Object.entries(barbiePhoneMap)) {
          if (event.key === key) {
            picoWin.pico8buttons[0] |= value;
            break;
          }
        }
    });

    document.addEventListener('keyup', function(event) {
        for (const [key, value] of Object.entries(barbiePhoneMap)) {
          if (event.key === key) {
            picoWin.pico8buttons[0] &= ~value;
            break;
          }
        }
    });
  } else {
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

  }
});