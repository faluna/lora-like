function testBit2symbol
  testBitArray1 = [1, 1, 1, 1]; % 4 bits per symbol, this value is 15.
  testBitArray2 = [1, 1, 1, 1, 1, 1, 1, 1]; % 8 bits per symbol, this value is 255.
  testBitArray3 = [1, 0, 1, 0, 1, 0, 1, 0,  ...
                   0, 1, 0, 1, 0, 1, 0, 1]; % 8 bits per symbol, this values are 85 and 170.
  loraInstance1 = Lora(125e3, 4);
  loraInstance2 = Lora(125e3, 8);

  resultSymbolArray1 = loraInstance1.bit2symbol(testBitArray1);
  if checkEqual(resultSymbolArray1, 15)
    comment = 'Test1 in bit2symbol function passed.';
  else
    comment = 'Test1 failed. Function which failed is bit2symbol.';
  end % End of if statement.
  disp(comment);

  resultSymbolArray2 = loraInstance2.bit2symbol(testBitArray2);
  if checkEqual(resultSymbolArray2, 255)
    comment = 'Test2 in bit2symbol function passed.';
  else
    comment = 'Test2 failed. Function which failed is bit2symbol.';
  end % End of if statement.
  disp(comment);
  resultSymbolArray3 = loraInstance2.bit2symbol(testBitArray3);
  if checkEqual(resultSymbolArray3, [85, 170])
    comment = 'Test3 in bit2symbol function passed.';
  else
    comment = 'Test3 failed. Function which failed is bit2symbol.';
  end % End of if statement
  disp(comment);
end % End of function.

