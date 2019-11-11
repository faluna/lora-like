function plotSymbol2chirpFreq
  testSymbolArray1 = [0, 0, 0, 0, 0]; % 5 symbols, this elements is all zero.
  testSymbolArray2 = [0, 3, 15, 63, 255]; % 5 symbols, this spreading factor is 8.
  loraInstance = Lora(125e3, 8);
  timeResolution = 1e6;

  [timeArray1, testChirpArray1] = loraInstance.symbol2chirpFreq(testSymbolArray1, timeResolution);
  [timeArray2, testChirpArray2] = loraInstance.symbol2chirpFreq(testSymbolArray2, timeResolution);

  figure
  plot(timeArray1, testChirpArray1);

  figure
  plot(timeArray2, testChirpArray2);
  
  demod = NaN(1, length(testChirpArray2));
  for i = 1:5
  demod((i - 1)*length(loraInstance.ChirpArray)+1: ...
      i*length(loraInstance.ChirpArray)) = (testChirpArray2((i - 1)*length(loraInstance.ChirpArray)+1: ...
      i*length(loraInstance.ChirpArray))- loraInstance.ChirpArray) * (2 .^ loraInstance.SpreadingFactor) / loraInstance.BandWidth;
  end
  demod = round(mod(demod,256));
  disp(demod);
  figure
  plot(timeArray2, demod);
end % End of function
