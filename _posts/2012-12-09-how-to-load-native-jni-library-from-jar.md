---
layout: post
title: How to Load Native JNI Library from JAR
tags: Java, JNI
disqusIdentifier: "152 http:\\/\\/frommyplayground.com\\/?p=152"
---

The <strong>JNI</strong> (Java Native Interface) is a framework that provides a bridge between Java and native applications. Java applications can define <strong>native methods</strong> which are implemented in dynamic library written in other languages such as C or C++. The dynamic library is able to call both static and dynamic methods. More information about JNI can be found on <a href="http://en.wikipedia.org/wiki/Java_Native_Interface">Wiki</a> or in tutorial <a href="http://netbeans.org/kb/docs/cnd/beginning-jni-linux.html">Beginning JNI with NetBeans</a> (for Linux).

The problem is that for loading such a dynamic library you have to call method <a href="http://docs.oracle.com/javase/6/docs/api/java/lang/System.html#load%28java.lang.String%29">System.load(String filename)</a> which requires an absolute filename. This approach is just fine if you have dynamic library outside the application's JAR archive, but when bundling dynamic library within the JAR it is necessary to extract the library into filesystem before loading it. And that's exactly what my code does.

<!--more-->

Our simple JNI class could look like this:

{% highlight java %}
public class HelloJNI {
  static {
    System.load("/path/to/my/library.so");
  }

  public native void hello();
}
{% endhighlight %}

To extract the library before loading it it's necessary to add some code into the <strong>static</strong> section. I wrapped it into a static method inside simple class called <strong><a href="https://github.com/adamheinrich/native-utils">NativeUtils</a></strong>. I decided to put it into separate class in order to have space for adding more features (like choosing the right dynamic library for host OS and architecture). The class can be found on my <a href="https://github.com/adamheinrich/native-utils">Github</a>.

The code is commented and self-explaining, so I don't have to write too much about it. Just three notes:

<ul>
    <li><strong>The file path is passed as string, not as instance of File.</strong> It is because File transforms the abstract path to system-specific (absolute path decision, directory delimiters) one, which could cause problems. It must be an absolute path (starting with '/') and the filename has to be at least three characters long (due to restrictions of <a href="http://docs.oracle.com/javase/6/docs/api/java/io/File.html#createTempFile%28java.lang.String,%20java.lang.String%29">File.createTempFile(String prefix, String suffix)</a>.</li>
    <li>The temporary file is stored into temp directory specified by <i>java.io.tmpdir</i> (by default it's the operating system's temporary directory). It should be automatically deleted when the application exits.</li>
    <li>Although the code has some try-finally section (to be sure that streams are closed properly in case an exception is thrown), it does not catch exceptions. <strong>The exception has to be handled by the application.</strong> I belive this approach is cleaner and has some benefits.</li>
</ul>

Final usage is pretty simple. :-) Just call method <strong>loadLibraryFromJar</strong> and handle exception somehow:

{% highlight java %}
import cz.adamh.NativeUtils;
public class HelloJNI {  
  static {   
    try {    
      NativeUtils.loadLibraryFromJar("/resources/libHelloJNI.so");   
    } catch (IOException e) {    
      e.printStackTrace(); // This is probably not the best way to handle exception :-)  
    }    
  }  

  public native void hello();    
}
{% endhighlight %}

<strong>Edited 2013-04-02:</strong> Lofi <a href="#comment-1760518031">came with a workaround</a> to release and delete our DLL from temporary directory on Widnows.

Get the whole code from my <a href="https://github.com/adamheinrich/native-utils">Github</a>!