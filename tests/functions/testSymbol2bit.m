function testSymbol2bit
  testSymbol1 = 15; % 4 bits per symbol, this value is 15.

  testSymbol2 = 255; % 8 bits per symbol, this value is 255.
  testSymbolArray = [85, 170]; % 8 bits per symbol, this values are 85 and 170.
  loraInstance1 = Lora(125e3, 4);
  loraInstance2 = Lora(125e3, 8);

  resultBit1 = loraInstance1.symbol2bit(testSymbol1);
  if checkEqual(resultBit1, [1, 1, 1, 1])
    comment = 'Test1 in symbol2bit function passed.';
  else
    comment = 'Test1 failed. Function which failed is symbol2bit.';
  end % End of if statement
  disp(comment);

  resultBit2 = loraInstance2.symbol2bit(testSymbol2);
  if checkEqual(resultBit2, [1, 1, 1, 1, 1, 1, 1, 1])
    comment = 'Test2 in bit2symbol function passed.';
  else
    comment = 'Test2 failed. Function which failed is bit2symbol.';
  end % End of if statement
  disp(comment);

  resultBitArray = loraInstance2.symbol2bit(testSymbolArray);
  if checkEqual(resultBitArray, [1, 0, 1, 0, 1, 0, 1, 0, ...
                                 0, 1, 0, 1, 0, 1, 0, 1])
    comment = 'Test3 in symbol2bit function passed.';
  else
    comment = 'Test3 failed. Function which failed is bit2symbol.';
  end % End of if statement
  disp(comment);
end % End of function
