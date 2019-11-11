function plotModulatedSignal
  testSymbolArray1 = [0, 0, 0, 0, 0]; % 5 symbols, this elements is all zero.
  testSymbolArray2 = [0, 3, 15, 63, 255]; % 5 symbols, this spreading factor is 8.
  loraInstance = Lora(125e3, 8);
  timeResolution = 1e6;

  [timeArray1, modulatedSignalArray1] = loraInstance.modulate(testSymbolArray1, timeResolution);
  [timeArray2, modulatedSignalArray2] = loraInstance.modulate(testSymbolArray2, timeResolution);

  figure
  plot(timeArray1, real(modulatedSignalArray1));

  figure
  plot(timeArray2, real(modulatedSignalArray2));
end % End of function
