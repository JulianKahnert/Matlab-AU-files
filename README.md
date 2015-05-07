# AU-Files in Matlab
These Matlab functions are based on the syntax of Matlabs `audio*` functions and will allow you to read and save your audio data in au-files.

Since the [AU file format](https://en.wikipedia.org/wiki/Au_file_format/) has no file size limit, it is an easy to use file format even for large files. The following functions are intended to work like the matlab built-in audio functions, such as `audioread`, `audiowrite` and `audioinfo`.

Whereas the advantage of these functions are, that they are built on standard matlab-code, so that there is no fear of a *will be removed in a future release*-warning! Furthermore, they will support more au-encodings.

## TGM_auinfo
	[stInfo] = TGM_auinfo(szFilename)
The `TGM_auinfo` function returns information of an au-file as a struct with the fieldnames:

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


## TGM_auread & TGM_auwrite
	[y, fs] = TGM_auwrite(szFilename,vInterval_smp)
	[] = TGM_auwrite(szFilename,y,fs)
These functions are similiar sturctured as the Matlab equivalents.


## TGM_au_test
Unit test for all the features, which are implemented. If you want to run these tests, please make sure that you have [SoX](http://sox.sourceforge.net) installed. Afterwards you can run `runtests('TGM_au_test.m')` to check the integrity of those feautres.


---------------
Please and contact me at <mailto:JTKahnert@icloud.com> for additional questions.

---------------
This projected is licensed under the terms of the MIT license.