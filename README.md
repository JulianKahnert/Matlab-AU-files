# AU-Files in Matlab

Mathworks removed the [auwrite](http://de.mathworks.com/help/matlab/ref/auwrite.html?searchHighlight=auwrite) function within R2015b, so here is an alternative and it's getting even better:
**Blockwise reading & writing of au-files with Matlab**, including different datatypes like int\* and float\*!

------

This toolkit is designed to help you with different au-file interactions. You can use the functions `au_info()`, `au_read()` and `au_write()` which are based on the syntax of Matlabs `audio*` functions. Furthermore, you can use the `AUFile`-class which is a performant way of blockwise reading and writing.

Since the [AU file format](https://en.wikipedia.org/wiki/Au_file_format/) has no limited file size, it is an easy to use file format even for large files. The following functions are intended to work like the Matlab built-in audio functions, such as `audioread`, `audiowrite` and `audioinfo`.

Whereas the advantage of this toolkit is, that it is built on standard Matlab-code, so that there is no fear of a *will be removed in a future release*-warning! Furthermore, it will support more au-encodings (like `int24`, `int32`, `float32` and `float64`).


## Workflow Examples (class)
Write data in a new au-file.
```matlab
iCH  = 5;
fs 	 = 48000;
obj  = AUFile('test.au', 'new', iCH, fs);
data = rand(10,iCH);
obj.write(data);
```

Read data from a new au-file, starting at sample `iStart` to `iStart+iNumber-1`:
```matlab
obj = AUFile('test.au', 'read');
obj.seek(iStart);
sig = obj.read(iNumber);
```
For more details, please have a look at the documentation (`doc AUFile`).

## au_* functions
The functions `au_info`, `au_read` and `au_write` are based on the audio* equivalents. That is why they have a very similar syntax. For more information, please check their documentation or help.

**Examples:**
```matlab
[stInfo, iDataOffset, iDataSize] = au_info('testfile.au')
[data, fs, stInfo] = au_read('testfile.au',[100 200])
au_write('testfile.au', rand(10*44100, 2)-.5)
au_write('testfile.au', rand(10*44100, 2)-.5, 44100, 3, 'float64')
```

## unit testing
There are unit testing skripts for both, AUFile-class and `au_*` functions. The au-files in `audio_files` have been created by [SoX](http://sox.sourceforge.net). Those files are encoded in different formats to check whether the read functions are working properly or not.

* **class:** `runtests('au_test_class.m')`
* **functions:** `runtests('au_test_func.m')`

---------------
Please open an issues for additional questions.

---------------
This project is licensed under the terms of the MIT license.