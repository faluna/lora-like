% this file implements lora modulation and ...
% this is wirtten by Hayato Kumazawa.

classdef Lora < dynamicprops
% requirement: format long
  properties
    BandWidth
    SpreadingFactor
    SymbolRate
    SymbolCycle
    BitRate
  end % End of properties

  properties (Constant) % List of selectable variables
    BandWidthList = [125e3, 250e3, 500e3]
    SpeadingFactorList = [7, 8, 9, 10, 11, 12]
  end % End of properties of Constant

  properties %(Hidden = true)
      ChirpArray = []
      ChirpPhaseArray = []
  end % End of Properties
  
  methods
    function obj = Lora(bandWidth, spreadingFactor)
      % Input:
      %   bandWidth : bandwidth on the simulation environment.
      %   spreadingFactor : spreading factor, it is the number of bits per symbol
      % Output:
      %   obj : Lora instance
      symbolRate = bandWidth / ( 2 .^ spreadingFactor );
      symbolCycle = 1 / symbolRate;
      bitRate = spreadingFactor * symbolRate;

      obj.BandWidth = bandWidth;
      obj.SpreadingFactor = spreadingFactor;
      obj.SymbolRate = symbolRate;
      obj.SymbolCycle = symbolCycle;
      obj.BitRate = bitRate;
    end % End of function

    function result = getBandWidthList(obj)
      % Return the band width list used by lora.
      % Output:
      %   result : band width list
      result = obj.BandWidthList;
    end % End of function

    function result = getSpreadingFactorList(obj)
      % Return the spreading factor list used by lora.
      % Output:
      %   result : spreading factor list
      result = obj.SpeadingFactorList;
    end % End of function

    function result = bit2symbol(obj, bitArray)
      % Convert a bit array into a symbol array
      % Input:
      %   bitArray : messages that bits line up.
      % Output:
      %   result : symbol array
      nBitArray = length(bitArray);
      result = NaN;
      if mod(nBitArray, obj.SpreadingFactor) == 0
        % if true
        binList = NaN(1, obj.SpreadingFactor); % Initialize binary list, e.g. [2.^0, 2.^1, ..., 2.^(SpreadngFactor)].
        for iBinList = 1:obj.SpreadingFactor   % Create binary list.
          binList(iBinList) = 2 .^ ( iBinList - 1);
        end % End of for statement
        nSymbolArray = nBitArray / obj.SpreadingFactor;
        symbolArray = NaN(1, nSymbolArray);
        for iSymbolArray = 1:nSymbolArray
          symbolArray(iSymbolArray) = sum(binList .* ...
            bitArray(obj.SpreadingFactor * (iSymbolArray - 1) + 1 ...
            :obj.SpreadingFactor * iSymbolArray));
        end % End of for statement
        result = symbolArray;
      else % if false
        comment = 'incorrect combination of number of bitArray elements' ...
                                        + 'and spreading factor';
        disp(comment);
      end % End if if statement
    end % End of function

    function [timeArray, chirpFreqArray] = symbol2chirpFreq(obj, symbolArray, timeResolution)
      % Convert symbol to chirp frequency.
      % Input:
      %   symbolArray: symbol array
      %   timeResolution : time resolution, the number of sampling points of time per second
      % Output:
      %   timeArray : time array 
      %   chirpFreqArray : chirp frequencty list which corresponds to symbol.
      %
%       symbolArray = obj.convert2gray(symbolArray);
      timeBoundList = obj.SymbolCycle - ( (2 .^ obj.SpreadingFactor - symbolArray) / (2 .^ obj.SpreadingFactor) ) * obj.SymbolCycle;
      plotPeriod = 1 / timeResolution;  % plot period
      totalPeriod = 0:plotPeriod:obj.SymbolCycle;
      nTotalPeriod = length(totalPeriod);
      nSymbolArray = length(symbolArray);
      chirpFreqArray = NaN(1, nTotalPeriod * nSymbolArray);
      obj.ChirpArray = (obj.SymbolRate * totalPeriod - 1 / 2) * obj.BandWidth;
      for iSymbol = 1:nSymbolArray
        headChirpFreqArray = obj.ChirpArray(totalPeriod > timeBoundList(iSymbol));
        tailChirpFreqArray = obj.ChirpArray(totalPeriod <= timeBoundList(iSymbol));
        chirpFreqArray((iSymbol - 1) * nTotalPeriod + 1: ...
                        iSymbol * nTotalPeriod) ...
          = [headChirpFreqArray, tailChirpFreqArray];
      end % End of for statement
      timeArray = linspace(0, obj.SymbolCycle * nSymbolArray, length(chirpFreqArray));
    end % End of function

    function [timeArray, modulatedSignalArray] = modulate(obj, symbolArray, timeResolution)
      % Modulate Symbol with lora modulation
      % Input:
      %   symbolArray : symbol array
      %   timeResolution : time resolution, the number of sampling points of time per second
      % Output:
      %   timeArray : time array 
      %   modulatedSignalArray : Signal modulated with lora modulation, this signal is complex number
%       symbolArray = obj.convert2gray(symbolArray);
      timeBoundList = obj.SymbolCycle - ( (2 .^ obj.SpreadingFactor - symbolArray) / (2 .^ obj.SpreadingFactor) ) * obj.SymbolCycle;
      plotPeriod = 1 / timeResolution;  % plot period
      totalPeriod = 0:plotPeriod:obj.SymbolCycle;
      nTotalPeriod = length(totalPeriod);
      nSymbolArray = length(symbolArray);
      modulatedSignalArray = NaN(1, nTotalPeriod * nSymbolArray);
      obj.ChirpPhaseArray = (obj.BandWidth * totalPeriod / 2 .^ (obj.SpreadingFactor) - 1) ...
                          .* (obj.BandWidth * totalPeriod / 2);
      for iSymbol = 1:nSymbolArray
        headModulatedArray = obj.ChirpPhaseArray(totalPeriod >= timeBoundList(iSymbol));
        tailModulatedArray = obj.ChirpPhaseArray(totalPeriod < timeBoundList(iSymbol));
        modulatedSignalArray((iSymbol - 1) * nTotalPeriod + 1: ...
                              iSymbol * nTotalPeriod) ...
          = [headModulatedArray, tailModulatedArray];
      end % End of for statement
      modulatedSignalArray = exp(1i * 2 * pi .* modulatedSignalArray);
      timeArray = linspace(0, obj.SymbolCycle * nSymbolArray, length(modulatedSignalArray));
    end % End of function

    function result = demodulate(obj,modulatedSignalArray)
      % Demodulate the signal modulated with LoRa modulation.
      % Input:
      %   modulatedSignalArray : the signal modulated with LoRa modulation.
      % Output:
      %   result : the signal which has a certain frequency in each symbol period.
      nTotalPeriod = length(obj.ChirpPhaseArray);
      demodulatedSignalArray = NaN(size(modulatedSignalArray));
      inverseChirpArray = exp(1i * -2 * pi .* obj.ChirpPhaseArray);
      for iSymbol = 1:fix(length(modulatedSignalArray) / nTotalPeriod)
        demodulatedSignalArray((iSymbol - 1) * nTotalPeriod + 1: ...
                                iSymbol * nTotalPeriod) ...
          = modulatedSignalArray((iSymbol - 1) * nTotalPeriod + 1: ...
                                  iSymbol * nTotalPeriod) ...
              .* inverseChirpArray;
      end % End of for statement
      result = demodulatedSignalArray;
    end % End of function

    function result = chirp2symbol(obj, demodulatedSignalArray, timeResolution)
      % Convert demodulated chirp signal into symbol.
      % Input:
      %   demodulatedSignalArray : a signal demodulated with LoRa method.
      %   timeResolution : time resolution, the number of sampling points of time per second
      % Output:
      %   result : symbol array
      plotPeriod = 1 / timeResolution; % plot period
      signalArrayReal = real(demodulatedSignalArray);
      signalArrayImag = imag(demodulatedSignalArray);
      nTotalPeriod = length(obj.ChirpPhaseArray);
      nSymbolArray = length(demodulatedSignalArray) / nTotalPeriod;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %       DiffFilter = [1, -1] ./ plotPeriod;
%       diffSigArrayReal = conv(signalArrayReal, DiffFilter, 'valid');
%       diffSigArrayImag = conv(signalArrayImag, DiffFilter, 'valid');
%       tempReal = diffSigArrayReal;
%       tempImag = diffSigArrayImag;
%       tempReal(nTotalPeriod:nTotalPeriod:end) = 0;
%       tempImag(nTotalPeriod:nTotalPeriod:end) = 0;
%       diffSigArrayReal = ([0, diffSigArrayReal] + [tempReal, 0]) / 2;
%       diffSigArrayImag = ([0, diffSigArrayImag] + [tempImag, 0]) / 2;
%       diffSigArrayReal(1:length(diffSigArrayReal) - 1:end) = ...
%           diffSigArrayReal(1:length(diffSigArrayReal) - 1:end) * 2;
%       diffSigArrayImag(1:length(diffSigArrayImag) - 1:end) = ...
%           diffSigArrayImag(1:length(diffSigArrayImag) - 1:end) * 2;
%       component1 = signalArrayReal .* diffSigArrayImag ...
%         - signalArrayImag .* diffSigArrayReal;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      diffFilter = [1, 0, -1] ./ (2 * plotPeriod);
           
      diffSigArrayReal = conv(signalArrayReal, diffFilter, 'valid');
      diffSigArrayImag = conv(signalArrayImag, diffFilter, 'valid');
     component1 = signalArrayReal(2  :length(signalArrayReal) - 1  ) ...
                    .* diffSigArrayImag ...
        - signalArrayImag(2  :length(signalArrayImag) - 1   ) ...
        .* diffSigArrayReal;  
    symbolSignalArray = (2 .^ obj.SpreadingFactor .* component1) ...
                  / (2 * pi * obj.BandWidth);
      result = NaN(1, nSymbolArray);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         diffDemodSigArray = conv(demodulatedSignalArray, diffFilter, 'valid');
%         symbolSignalArray = (abs(diffDemodSigArray) * (2 .^ obj.SpreadingFactor)) ...
%                             / (2 * pi * obj.BandWidth);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        symbolSignalArray = round(mod(symbolSignalArray, 2 .^ obj.SpreadingFactor));
        disp(symbolSignalArray);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for iSymbol = 1:nSymbolArray
%         switch iSymbol
%           case 1
%             result(1) = mean(symbolSignalArray(1:nTotalPeriod-2));
%           case nSymbolArray
%             result(nSymbolArray) = mean(symbolSignalArray((iSymbol - 1) * nTotalPeriod + 1:length(symbolSignalArray) - 1));
%           otherwise
%             result(iSymbol) = mean(symbolSignalArray((iSymbol - 1) * nTotalPeriod + 1:iSymbol * nTotalPeriod - 2)); % the head and tail of each symbol can't differentiate, so there are excluded.
%         end % End of switch statement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        result(iSymbol) = obj.judgeSymbol(symbolSignalArray((iSymbol - 1) * nTotalPeriod + 1+1:iSymbol * nTotalPeriod - 2));
%         result(iSymbol) = obj.judgeSymbol(symbolSignalArray((iSymbol - 1) * nTotalPeriod + 1:iSymbol * nTotalPeriod));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      end % End of for statement
%       for iSymbol = 1:nSymbolArray
%             result(nSymbolArray) = mean( ...
%             symbolSignalArray((iSymbol - 1) * nTotalPeriod + 1 ...
%                                 :iSymbol * nTotalPeriod));
%       end % End of for statement
%       result = round(result);
%       result(result > (2 .^ obj.SpreadingFactor)) = 2 ^ obj.SpreadingFactor;
%       result(result <= -1) = 2 .^ obj.SpreadingFactor;
        result = mod(result, 2 .^ obj.SpreadingFactor);
%       result = obj.convertGray(result);
    end % End of function

    function result = symbol2bit(obj, symbolArray)
      % convert symbol array into bit array ( = messages ).
      % Input:
      %   symbolArray : symbol array
      % Output:
      %   result : bit array
      nSymbolArray = length(symbolArray);
      binSymbolArray = de2bi(symbolArray, obj.SpreadingFactor);
      result = NaN(1, nSymbolArray * obj.SpreadingFactor);
      for iSymbol = 1:nSymbolArray
        result((iSymbol - 1) * obj.SpreadingFactor + 1:iSymbol * ...
            obj.SpreadingFactor) ...
          = binSymbolArray(iSymbol,:);
      end % End of if statement
    end % End of function
  end % End of methods
  
  methods (Static)
      function result = convert2gray(normalArray)
          % convert normal codes into gray codes.
          % Input:
          %     normalArray : normal number codes.
          % Output:
          %     result : gray codes numbers.
          result = bitxor(normalArray, floor(normalArray / 2));
      end % End of function.
      
      function result = convertGray(grayArray)
          % convert gray codes into normal codes.
          % Input:
          %     grayArray : gray codes array
          % Output:
          %     result : normal codes.
          binGrayArray = dec2bin(grayArray);
          result = NaN(size(grayArray));
          for iBinGrayArray = 1:size(binGrayArray, 1)
              binGray = binGrayArray(iBinGrayArray,:);
              tempResult = NaN(size(binGray));
              for iBinGray = 1:length(binGrayArray(iBinGrayArray))
                  if iBinGray == 1
                      tempResult(iBinGray) = binGray(iBinGray);
                  else
                      tempResult(iBinGray) = dec2bin(bitxor(double(tempResult(iBinGray - 1)), ...
                      double(binGray(iBinGray))));
                  end % End of if statement
              end % End of for statement
              result(iBinGrayArray) = bin2dec(tempResult);
          end % End of for statement
      end % End of function
      
      function result = judgeSymbol(symbolSignalArray)
          % select a symbol by majority vote.
          % input:
          %     symbolSignalArray : symbol signal array
          % output:
          %     result : symbol decided by majority vote.
          symbolMap = containers.Map(-Inf,-Inf);
          for iSymbol = 1:length(symbolSignalArray)
              tempSymbol = symbolSignalArray(iSymbol);
              if isKey(symbolMap, tempSymbol)
                  symbolMap(tempSymbol) = symbolMap(tempSymbol) + 1;
              else
                  symbolMap(tempSymbol) = 1;
              end % End of if statement
          end % End of for statement
          
          symbolKeyList = keys(symbolMap);
          symbolKeyList = cell2mat(symbolKeyList);
          tempMaxCount = -Inf;
          result = NaN;
          for iKey = 1:length(symbolKeyList)
              if tempMaxCount < symbolMap(symbolKeyList(iKey))
                  result = symbolKeyList(iKey);
                  tempMaxCount = symbolMap(symbolKeyList(iKey));
              end % End of if statement
          end % End of for statement
      end % End of function
  end % End of methods
end % End of Lora Class
