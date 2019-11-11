function plotDemodulatedSignal
  testSymbolArray1 = [0, 0, 0, 0, 0]; % 5 symbols, this elements is all zero.
  testSymbolArray2 = [0, 3, 15, 63, 255]; % 5 symbols, this spreading factor is 8.
  loraInstance = Lora(125e3, 8);
  timeResolution = 1e4;
  [timeArray1, modulatedSignalArray1] = loraInstance.modulate(testSymbolArray1, timeResolution);
  [timeArray2, modulatedSignalArray2] = loraInstance.modulate(testSymbolArray2, timeResolution);
  demodulatedSignalArray1 = loraInstance.demodulate(modulatedSignalArray1);
  demodulatedSignalArray2 = loraInstance.demodulate(modulatedSignalArray2);

  figure
  plot(timeArray1, real(demodulatedSignalArray1));

  figure
  plot(timeArray2, real(demodulatedSignalArray2));
end % End of function
