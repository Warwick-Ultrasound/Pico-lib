function pico_flash_led(device, key)
   % if key < 0: flash LED indefinitely
   % if key = 0: stop LED flashing
   % if key > 0: flash LED [key] times
   invoke(device, "ps2000aFlashLed", key);
end