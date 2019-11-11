# LoRaライクな変調
matlabで実装したLoRaライクな変調モジュール
## Usage
### インスタンス化
Loraクラスをインスタンス化
```matlab
  loraInstance = Lora(BW, SF);
```
* BW:帯域幅[Hz]
* SF:拡散ファクタ

### LoRaWANで規定されている帯域幅と拡散ファクタの取得
```matlab
  loraInstance.getBandWidthList() % BW
  loraInstance.getSpreadingFactorList() % SF
```

### binary配列をシンボル配列に変換
```matlab
  loraInstance = Lora(125e3, 8);
  bitArrray = [1, 1, 1, 1, 1, 1, 1, 1];
  symbolArray = loraInstance.bit2symbol(bitArrray);
  % result : 255
```

### シンボル配列をチャープ周波数に変換
```matlab
  loraInstance = Lora(125e3, 8);
  symbolArray = [0, 3, 15, 63, 255];
  timeResolution = 1e2;

  [timeArray, ChirpArray] = loraInstance.symbol2chirpFreq(symbolArray, timeResolution);
```
* timeResolution:時間解像度, 1秒間あたりのプロット数(サンプリング周波数と捉えても良い(異なる場合も有))
* timeArray:時間軸の配列
* ChirpArray:チャープ周波数の配列

### 変調信号生成
```matlab
  loraInstance = Lora(125e3, 8);
  symbolArray = [0, 3, 15, 63, 255];
  timeResolution = 1e2;

  [timeArray, modulatedSignalArray] = loraInstance.modulate(symbolArray, timeResolution);
```

### 変調信号を復調
loraインスタンス(loraInstance)と変調信号(modulatedSignalArray)生成済とする.
```matlab
  demodulatedSignalArray = loraInstance.demodulate(modulatedSignalArray);
```

### 復調した信号をシンボルに変換
loraInstance, demodulatedSignalArray 生成済とする.
```matlab
  symbolArray = loraInstance.chirp2symbol(demodulatedSignalArray, timeResolution);
```

### シンボル配列をbainary配列に変換
loraIntance, symbolArray 生成済とする.
```matlab
  bitArray = loraInstance.symbol2bit(symbolArray);
```
