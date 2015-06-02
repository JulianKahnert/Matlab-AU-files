# AU-Files in Matlab
These Matlab functions are based on the syntax of Matlabs `audio*` functions and will allow you to read and save your audio data in au-files.

Since the [AU file format](https://en.wikipedia.org/wiki/Au_file_format/) has no file size limit, it is an easy to use file format even for large files. The following functions are intended to work like the Matlab built-in audio functions, such as `audioread`, `audiowrite` and `audioinfo`.

Whereas the advantage of these functions are, that they are built on standard Matlab-code, so that there is no fear of a *will be removed in a future release*-warning! Furthermore, they will support more au-encodings (like `int24`, `int32`, `float32` and `float64`) and **blockwise reading and** ***writing***.

## au_info()
The `au_info` function returns information of an au-file as a struct. The first ten fields of the struct are same as in the Matlab function `audioinfo`. The last field is au-specific:

	'Filename'          A string containing the name of the file
	'CompressionMethod' Method of audio compression in the file
	'NumChannels'       Number of audio channels in the file.
	'SampleRate'        The sample rate (in Hertz) of the data in the file.
	'TotalSamples'      Total number of audio samples in the file.
	'Duration'          Total duration in seconds of the audio in the file.
	'Title'             Always empty for au-files.
	'Comment'           Always empty for au-files.
	'Artist'            Always empty for au-files.
	'BitsPerSample'     Number of bits per sample in the au-file. Valid
	                    values are 8,16,24,32, or 64.

	'Datatype'          Format in which the values should be written. Valid
	                    strings are int8, int16, int24, int32, float32
	                    or float64.

`DATAOFFSET` returns the offset after which the audio data starts, it is equal to the size of the header. `DATASIZE` is specified as the size of the au data.

Usage example:
```matlab
[stInfo, iDataOffset, iDataSize] = au_info('testfile.au')
```

## au_read()
This function is similar structured as the Matlab equivalent.

Usage example:
```matlab
[data, fs, stInfo] = au_read('testfile.au',[100 200])
```

## au_write()
This function is similar structured as the Matlab equivalent (audiowrite). With the advantage, that you can choose between different types of encodings and **blockwise writing**.

`AU_WRITE(FILENAME, DATA, FS)` writes the audio data in `DATA` with a given FS in a au-file, which was specified by the string `FILENAME`. If a au-file with `FILENAME` already exists, it will be overwritten.
`AU_WRITE(FILENAME, DATA, FS, START)` writes the `DATA` in the interval `START` through `START+size(DATA,1)` for each channel in the file. If you set `START` to `Inf`, `au_write` will append `DATA` on an existing au-file. Furthermore AU_WRITE will overwrite all existing samples if START is not specified or START = [].

`au_write(FILENAME, DATA, FS, START, DATATYPE)` writes a au-file with a specified `DATATYPE`. Valid strings are *int8*, *int16*, *int24*, *int32*, *float32* or *float64*.

Usage examples:
```matlab
au_write('testfile.au', rand(10*44100, 2)-.5)
au_write('testfile.au', .9*ones(5,2), 44100, 3)
au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'int32')
au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'float64')
```


## au_test()
Unit test for all the features, which are implemented. Just run `runtests('au_test.m')` to check it.
The existing au-files have been created by [SoX](http://sox.sourceforge.net). Those files are encoded in different formats to check whether the read functions are working properly or not.

---------------
Please open an issues for additional questions.

---------------
This project is licensed under the terms of the MIT license.