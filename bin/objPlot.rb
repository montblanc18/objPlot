#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# Using Right Accention and declination of a star, this program caluculate the direction of that star relative to the position on earth which you choose.
#
####################
# 更新履歴
####################
#
# YYMMDD ver.  author  content
# XXXXXX 1.0   hikaru  動くようにした
# 141129 1.1   hikaru  optionをブロックで処理するようにした。-sオプションを加える。
# 150123 1.2   hikaru  プログラム名を変えた。radec.rb->pointObject.rb
# 150201 1.2.1 hikaru  変数および関数名を修正した。Observatoryは正午ピッタリに南中すると仮定中。
# 150201 1.3.0 hikaru   時刻をすべてUTCで起算。観測所の情報を変換することで好きな観測所を選べるようにした。
# 170426 2.0.0 hikaru/montblanc18 upload to github and translate to English.

require "opengl"
require "glut"
require "matrix"
require "optparse"
require "glu"

##############
# parameters #
##############
MonthToDay = [0,31,59,90,120,151,181,212,243,273,304,334]
ObservatoryLat = 35.7866 # Latitude of observatory
ObservatoryLon = 138.4806 # Longtidue of observatory
ObservatoryRadius = 900 + 640000 # height of observatory plus radius of the earth
ObservatoryTimeOffset = 60 * 60 * 9 # UTC+9:00 in Japan

#############
# functions #
#############

def DegToRad(deg)
  rad = deg.to_f * 2 * Math::PI / 360.0
  return rad
end

display = proc {
  day = Time.now.utc
  GL.Clear(GL::COLOR_BUFFER_BIT)
  Celestial()
  OrbitCelestial()
  Sun(day)
  #GL.Translated(0.0,0,0.01)
  Object()
  Earth()
  Observatory(day)
  DrawAxis()
  GLUT.SwapBuffers()
}

timer = proc {
  GL.Rotate(1.0, 0.0, 1.0, 0.0)
  GLUT.PostRedisplay()
  GLUT.TimerFunc(10, timer, 0)
}

def Observatory(tday)
  GL.Begin(GL::GL_POINTS)
  GL.Color3f(1.0, 1.0, 0.0)
  day = tday
  #print day
  #day = Time.local(2000,3,23,12,0,0) #デバッグ用。春分を指定。
  decc= 2 * Math::PI / 360.to_f * ObservatoryLat
  raa = 2 * Math::PI * ((MonthToDay[((day.month).to_i - 1)] + day.day-82)).to_f / 365.0 #82は年始から3/23までの日数。現在のグリニッジ天文台の位置。
  raa += 2 * Math::PI * ObservatoryLon/365.0 #観測所の経度の分回転する。
  #更に何度回転しているか、太陽が正午に南中すると仮定して考える。
  raa = raa + 2 * Math::PI * ((day.hour - 12) * 15 + day.min * 0.25) / 360.to_f
  MakeSphere(0.1, 0.01, raa, decc);
  GL.End()
end

def Celestial()
  GL.Color3f(0.0, 1.0, 1.0)
  GLUT.WireSphere(1.0, 20.0, 20.0)
end

def OrbitCelestial()
  GL.Color3f(1.0, 1.0, 1.0)
  GLUT.WireSphere(0.5, 10.0, 10.0)
end

def Sun(tday)
  GL.Begin(GL::GL_POINTS)
  GL.Color3f(1.0, 1.0, 0.0)
  #GLUT.WireSphere(0.1, 10.0, 10.0)
  day = tday
  #print day,"\n"
  day += ObservatoryTimeOffset #観測所がUTCに対してどれだけずれているか秒単位で与える。
  #day = day.local
  raa = 2*Math::PI*((MonthToDay[((day.month).to_i - 1)] + day.day-82)).to_f / 365.0
  sunDec = 23.5 * Math::PI / 180.0
  #decc = 0
  if raa%180 ==0 && raa%90 == 0 then
    decc = 0
  end
  if raa%180 !=0 && raa%90 == 0 && raa%270 != 0 then
    decc = 23.5
  end
  if raa%180 !=0 && raa%90 == 0 && raa%270 == 0 then
    decc = -23.5
  end
  if raa%180 !=0 && raa%90 != 0 then

    dir1 = Vector[1 / Math.tan(raa),1,Math.tan(sunDec)]
    dir2 = Vector[1 / Math.tan(raa),1,0]
    decc = Math.acos((dir1.inner_product(dir2)).to_f / (dir1.r * dir2.r).to_f)
    #deccが必ず正になる。ので注意。下で補正。
    
    if raa > Math::PI or raa < 0 then 
      decc = -decc
    end
    
  end
  #色を指定
  #p raa,decc
  #GL.Color3d(0.0,0.0,1.0)
  #天体の位置に球体をつくる。
  MakeSphere(0.5, 0.1, raa, decc)
  #p raa,decc
  GL.End()
end

def Object()
  GL.Begin(GL::GL_POINTS)
  #色を指定
  GL.Color3d(1.0,0.0,0.0)
  #天体の位置に球体をつくる。
  MakeSphere(1.0, 0.1, RA, DEC)
  GL.End()
end

def Earth()
  #GL.Begin(GL_POINTS)
  #現在時刻から地球の赤経、赤緯を得る
  GL.Color3d(0.0, 0.0, 1.0)
  GLUT.WireSphere(0.1, 10.0, 10.0)
=begin
     day = Time.now
     raa = 2*Math::PI*((MonthToDay[((day.month).to_i-1)] + day.day-91)).to_f/365.0 + Math::PI
     decc = 0#赤緯は0
     #色を指定
     #p raa,decc
     GL.Color3d(0.0,0.0,1.0)
     #天体の位置に球体をつくる。
     makeSphere(0.5,0.1,raa,decc)
     #p raa,decc
     GL.End()
=end
end

#点で球体をつくる
def MakeSphere(positionR, radius, ra, dec)
  pointNum = 50
  i = 0
  while i<pointNum do
    j = 0
    while j<pointNum do
      l_theta = 2 * Math::PI*i.to_f / pointNum.to_f
      l_phi = 2 * Math::PI*j.to_f / pointNum.to_f
      #中心座標
      x = positionR * Math.cos(ra) * Math.cos(dec)
      y = positionR * Math.sin(ra) * Math.cos(dec)
      z = positionR * Math.sin(dec)
      #各ポイント
      x = x + radius * Math.cos(l_phi) * Math.sin(l_theta)
      y = y + radius * Math.sin(l_phi) * Math.sin(l_theta)
      z = z + radius * Math.cos(l_theta)
      #座標を回転する
      zz = -x #なぜかマイナスつけるとうまくいく。
      xx = y
      yy = z
      #プロット
      GL.Vertex3d(xx, yy, zz)
      j=j+1
    end
    i=i+1
  end
end

#軸を書く関数
def DrawAxis()
  #axis[4][3]=[[0.0,0.0,0.0],[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]]
  GL.Begin(GL::GL_LINES);
  #x軸
  GL.Color3dv(1.0, 0.0, 0.0)
  GL.Vertex3dv(0.0, 0.0, 0.0)
  GL.Vertex3dv(0.0, 0.0, -2.0)
  #y軸
  GL.Color3dv(0.0, 1.0, 0.0)
  GL.Vertex3dv(0.0, 0.0, 0.0)
  GL.Vertex3dv(2.0, 0.0, 0.0)
  #z軸
  GL.Color3dv(0.0, 0.0, 1.0)
  GL.Vertex3dv(0.0, 0.0, 0.0)
  GL.Vertex3dv(0.0, 2.0, 0.0)
  GL.End()
end


###
# 終了時の処理。
###
Signal.trap(:INT){
  print("
I received Ctrl+C.
Terminate this program.
")
  exit(0)
}

def PrintMessage()
  str = sprintf("
Big Blue     : Earth
small yellow : Observatory (Lat:%f, Lon:%f)
Big Yellow   : Sun
Big Red      : Object
Large Blue   : Celestial Sphere

Please press Ctrl+c if you want to terminate this program.
",ObservatoryLat,ObservatoryLon)
  print(Time.now.utc,str)
end


def Initialize()
  
  
end

########
# main #
########
if __FILE__==$0
  opts={}
  #引数の設定
  #座標系が異なるので合わせる
  ARGV.options do |o|
    o.on("-r X","--ra","Right Accension [deg]"){|x| opts[:ra]=x}
    o.on("-d X","--dec","Declination [deg]"){|x| opts[:dec]=x}
    o.on("-s","--stop","Stop Spin"){|x| opts[:spin]=x}
    o.parse!
  end

  initialize()
  
  RA=DegToRad(opts[:ra].to_f)
  DEC=DegToRad(opts[:dec].to_f)
  #引数の設定
  PrintMessage()
  GLUT.Init()#GLUTおよびOpenGL環境の初期化
  GLUT.InitWindowSize(500, 500)
  GLUT.CreateWindow("Celestial Dome")#windowを開く。引数を名前にする。
  #gluLookAt(1,0,0,0,0,0,0,1,0)#カメラの視点の操作
  GLUT.DisplayFunc(display)#引数に関数のポインタをとる。その関数を記述する。
  GL.ClearColor(0.3, 0.3, 0.3, 0.3)#ウインドウを塗りつぶす色を指定。R,G,B,透明度。

  if true != opts[:spin]
    GLUT.TimerFunc(10, timer, 0)
  end
  GLUT.MainLoop() # nearly equal while loop. By calling this function, program becomes wait mode.
  
end
