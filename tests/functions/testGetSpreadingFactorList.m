function testGetSpreadingFactorList
  loraInstance = Lora(125e3, 8);
  spreadingFactorList = loraInstance.getSpreadingFactorList;

  testResult = checkEqual(spreadingFactorList, [7, 8, 9, 10, 11, 12]);
  if testResult
    comment = 'Ok, GetSpreadingFactorList function is passed.';
  else
    comment = 'Test failed. Function which failed is GetSpreadingFactorList.';
  end % End of if statement
  disp(comment);
end% End of function
