#概要
OpenGLを使って、3次元上で現時刻での天体(赤)・地球(青)・太陽(黄色)を球体で表現する。  
また、地球上の指定した座標(黄色)を同時に描画する。  
一番大きな水色の球は、天球面を表現している。

#使い方
`
$ ruby objPlot.rb -r <天体のra> -d <天体のdec>  
$ ruby objPlot.rb -h  
Usage: objPlot [options]  
    -r, --ra X                       Right Accension [deg]  
    -d, --dec X                      Declination [deg]  
    -s, --stop                       Stop Spin  
`
