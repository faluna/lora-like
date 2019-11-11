function testChirp2symbol
  testSymbolArray1 = [0, 0, 0, 0, 0]; % 5 symbols, this elements is all zero.
  testSymbolArray2 = [0, 3, 15, 63, 255]; % 5 symbols, this spreading factor is 8.
  loraInstance = Lora(125e3, 8);
  timeResolution = 1e6;

  [~, modulatedSignalArray1] = loraInstance.modulate(testSymbolArray1, timeResolution);
  [~, modulatedSignalArray2] = loraInstance.modulate(testSymbolArray2, timeResolution);
  demodulatedSignalArray1 = loraInstance.demodulate(modulatedSignalArray1);
  demodulatedSignalArray2 = loraInstance.demodulate(modulatedSignalArray2); 
  resultSymbolArray1 = loraInstance.chirp2symbol(demodulatedSignalArray1, timeResolution);
  resultSymbolArray2 = loraInstance.chirp2symbol(demodulatedSignalArray2, timeResolution);
   
  result1 = checkEqual(resultSymbolArray1, testSymbolArray1);
  result2 = checkEqual(resultSymbolArray2, testSymbolArray2);
  if result1
    comment = 'Ok. Test1 of chirp2symbol function passed.';
  else
    comment = 'Test1 failed. Function which is failed is chirp2symbol.';
  end % End of if statement
  disp(comment);

  if result2
    comment = 'Ok. Test2 of chirp2symbol function passed.';
  else
    comment = 'Test2 failed. Function which is failed is chirp2symbol.';
  end % End of if statement
  disp(comment);
  disp(resultSymbolArray2);
end % End of function
