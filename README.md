# AU-Files in Matlab

Mathworks removed the [auwrite](http://de.mathworks.com/help/matlab/ref/auwrite.html?searchHighlight=auwrite) function within R2015b, so here is an alternative and it's getting even better:
**Blockwise reading & writing of au-files with Matlab**, including different datatypes like int\* and float\*!

------

This toolkit is designed to help you with different au-file interactions. You can use the functions `au_info()`, `au_read()` and `au_write()` which are based on the syntax of Matlabs `audio*` functions. Furthermore, you can use the `AUFile`-class which is a performant way of blockwise reading and writing.

Since the [AU file format](https://en.wikipedia.org/wiki/Au_file_format/) has no limited file size, it is an easy to use file format even for large files. The following functions are intended to work like the Matlab built-in audio functions, such as `audioread`, `audiowrite` and `audioinfo`.

Whereas the advantage of this toolkit is, that it is built on standard Matlab-code, so that there is no fear of a *will be removed in a future release*-warning! Furthermore, it supports more au-encodings (like `int24`, `int32`, `float32` and `float64`).

## au_* functions
The syntax of the `au_info`, `au_read` and `au_write` functions is inspired by the audio* equivalents from mathworks. For more information, please check their documentation or help.

**Examples:**
```matlab
[stInfo, iDataOffset, iDataSize] = au_info('testfile.au')
[data, fs, stInfo] = au_read('testfile.au',[100 200])
au_write('testfile.au', rand(10*44100, 2)-.5)
au_write('testfile.au', rand(10*44100, 2), 48000, 3, 'float64')
```

## Workflow Examples (class)
Write data in a new au-file.
```matlab
number_of_channels = 5;
samplerate = 48000;
obj = AUFile('test.au', 'new', number_of_channels, samplerate);
data = rand(10,iCH);
obj.write(data);
```

Read data from a new au-file, starting at sample `iStart` to `iStart+iNumber-1`:
```matlab
iStart = 5;
iNumber = 10;
obj = AUFile('test.au', 'read');
obj.seek(iStart);
data1 = obj.read(iNumber);	% read samples 5 to 14
data2 = obj.read(iNumber);	% read samples 15 to 24
```
For more details, please have a look at the documentation (`doc AUFile`).

## unit testing
There are unit testing skripts for both, AUFile-class and `au_*` functions. The au-files in `audio_files` have been created by [SoX](http://sox.sourceforge.net). Those files are encoded in different formats to check whether the read functions are working properly or not.

* **class:** `runtests('au_test_class.m')`
* **functions:** `runtests('au_test_func.m')`

---------------
Please open an issue for additional questions.

---------------
Copyright (c) 2015 Julian Kahnert
Jade University of Applied Sciences

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject
to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.