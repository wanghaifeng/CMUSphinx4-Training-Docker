环境：Mac OSX，v10.11.2；Homebrew已经安装好（http://brew.sh/）
wordpress版: http://www.nsshell.com/archives/465

[toc]
# 准备

## 下载工具源码
---
* cmusphinxbase
* pocketsphinx
* sphinxtrain
* CMU-Cam_Toolkit_v2 (http://www.speech.cs.cmu.edu/SLM/)

## 从源码编译安装工具软件
---

    tar  zxvf <tool>.tar.gz 
    configure
    make
    make install

*注: CMU-Cam_Toolkit_v2 只需要在src目录下执行make install，编译后命令安装到../bin目录*

CMU-Cam_Toolkit_v2编译及命令参考

编译过程中缺少的依赖包可以使用brew命令安装


# 创建语言模型(lm)
## 创建项目
---
项目目录位置：/lm_training/words/

    cd /lm_training
    sphinxtrain -t words setup
    
然后进入/lm_training/words/etc目录，检查sphine_train.cfg文件已经创建。

## 准备文本文件
---
文本文件的准备参考： http://cmusphinx.sourceforge.net/wiki/tutoriallm#text_preparation。

用文本工具生成一个words.txt文件，将文件保存到/lm_training/words/etc/

    <s> I'm good at sports </s>
    <s> I used to develop websites </s>
    <s> you should talk to him about it </s>
    <s> what do you think about living in a new city </s>
    <s> Keep up with your good work </s>
    <s> You must cover all of the points </s>
    <s> The letter must be well-organised </s>
    <s> I await your prompt response </s>
    <s> Brothers and sisters </s>
    <s> That is the train station </s>
    <s> Jack went to library yesterday </s>
    <s> We know you will come to China </s>
    <s> I had a fight with my brother </s>
    <s> bed </s>
    <s> monster </s>
    <s> sweater </s>
    <s> bus </s>
    <s> monkey </s>
    <s> bird </s>

## 转换文本为模型文件
---
可选模型文件格式有：ARPA文本格式，BIN二进制格式，DMP二进制格式（淘汰、不推荐）

依次用到如下命令，得到words.lm.DMP文件

命令及步骤参考：http://cmusphinx.sourceforge.net/wiki/tutoriallm#arpa_model_training

    text2wfreq </lm_training/words/etc/words.txt | wfreq2vocab >/lm_training/words/etc/words.tmp.vocab
    text2idngram -vocab/lm_training/words/etc/words.tmp.vocab -temp /tmp </lm_training/words/etc/words.txt  >/lm_training/words/etc/words.idngram
    idngram2lm -vocab_type 0 -idngram/lm_training/words/etc/words.idngram -vocab words.tmp.vocab -arpa/lm_training/words/etc/words.arpa
    sphinx_lm_convert -i /lm_training/words/etc/words.arpa -o/lm_training/words/etc/words.lm.bin

##准备wav文件
---
Wav文件的准备过程参考： http://cmusphinx.sourceforge.net/wiki/tutorialadapt#recording_your_adaptation_data

安装Audacity 或者 Wavesurfer录音软件，将words.txt录制成一个大的语音文件，然后在按照句子分割保存。注意：wav文件格式要求是16KHz(8KHz)，16Bit，单声道。可以使用ffmpeg工具转换。或者 libav-tools(avconv)

将分割后的wav文件放到/lm_training/words/wav/目录下

    ffmpeg -y -i 原声音.mp3 -acodec pcm_s16le -ac 1 -ar 16000 output_file_1.wav

批转换wav文件脚本

    for FILENAME in $(find . -type f -name '*.wav' -print | sed 's/^\.\///'); 
    do 
      echo $FILENAME;
      ffmpeg -y -i $FILENAME -acodec pcm_s16le -ac 1 -ar 16000 output.wav; 
      rm $FILENAME; 
      mv output.wav $FILENAME; 
    done

## 准备辅助文件
---
参考：http://cmusphinx.sourceforge.net/wiki/tutorialam#data_preparation

在/lm_training/words/etc/目录下生成如下文本文件：

words.dic -- 可以将words.txt文件上传到：http://www.speech.cs.cmu.edu/tools/lmtool-new.html,转换得到.dic文件
 * words_train.fileids
 * words_train.transcription
 * words_test.fileids
 * words_test.transcription 
 * words.phone
 
命令列表

    pocketsphinx_mdef_convert -text en-us/mdef en-us/mdef.txt

    sphinx_fe -argfile en-us/feat.params -samprate 16000 -c etc/words_train.fileids  -di . -do . -ei wav -eo mfc -mswav yes

    ./bw  -hmmdir en-us  -moddeffn en-us/mdef.txt  -ts2cbfn .ptm.  -feat 1s_c_d_dd  -svspec 0-12/13-25/26-38  -cmn current  -agc none  -dictfn cmudict-en-us.dict -ctlfn etc/words_train.fileids -lsnfn etc/words_train.transcription -accumdir .

    ./mllr_solve     -meanfn en-us/means     -varfn en-us/variances     -outmllrfn mllr_matrix -accumdir .
    
    cp -a en-us en-us-adapt
    
    ./map_adapt     -moddeffn en-us/mdef.txt     -ts2cbfn .ptm.     -meanfn en-us/means     -varfn en-us/variances     -mixwfn en-us/mixture_weights     -tmatfn en-us/transition_matrices     -accumdir .     -mapmeanfn en-us-adapt/means     -mapvarfn en-us-adapt/variances     -mapmixwfn en-us-adapt/mixture_weights     -maptmatfn en-us-adapt/transition_matrices
    
    ./mk_s2sendump     -pocketsphinx yes     -moddeffn en-us-adapt/mdef.txt     -mixwfn en-us-adapt/mixture_weights     -sendumpfn en-us-adapt/sendump

参考连接
---
http://cmusphinx.sourceforge.net/wiki/tutorialam

http://cmusphinx.sourceforge.net/wiki/tutoriallm

http://cmusphinx.sourceforge.net/wiki/tutorialadapt

http://blog.sina.com.cn/s/blog_6e09b50f0101myql.html
