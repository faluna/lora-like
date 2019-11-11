function testGetBandWidthList
  loraInstance = Lora(125e3, 8);
  bandWidthList = loraInstance.getBandWidthList;

  testResult = checkEqual(bandWidthList, [125e3, 250e3, 500e3]);
  if testResult
    comment = 'Ok, GetBandWidthList function is passed.';
  else
    comment = 'Test failed. Function which failed is GetBandWidthList.';
  end % End of if statement
  disp(comment);
end% End of function

