# AU-Files in Matlab
These Matlab functions are based on the syntax of Matlabs `audio*` functions and will allow you to read and save your audio data in au-files.

Since the [AU file format](https://en.wikipedia.org/wiki/Au_file_format/) has no file size limit, it is an easy to use file format even for large files. The following functions are intended to work like the Matlab built-in audio functions, such as `audioread`, `audiowrite` and `audioinfo`.

Whereas the advantage of these functions are, that they are built on standard Matlab-code, so that there is no fear of a *will be removed in a future release*-warning! Furthermore, they will support more au-encodings.

## au_info
```matlab
[stInfo] = au_info(szFilename)
```

The `au_info` function returns information of an au-file as a struct with the fieldnames:

* Filename
* CompressionMethod
* NumChannels
* SampleRate
* TotalSamples
* Duration
* Title
* Comment
* Artist
* BitsPerSample


## au_read
This function is similar structured as the Matlab equivalent.
```matlab
[data, fs] = au_write(szFilename,vInterval_smp)
```

## au_write
This function is similar structured as the Matlab equivalent (audiowrite). With the advantage, that you can choose between different types of encodings. Just set the input variable `szEncoding` to one of the following strings:

* 'int8'
* 'int16'
* 'int24'
* 'int32'

```matlab
au_write(szFilename,y,fs,szEncoding)
```


## au_test
Unit test for all the features, which are implemented. If you want to run these tests, please make sure that you have [SoX](http://sox.sourceforge.net) installed. Afterwards you can run `runtests('au_test.m')` to check the integrity of those features.


---------------
Please open an issues for additional questions.

---------------
This project is licensed under the terms of the MIT license.