breed[comiloes comilao]
breed[limpadores limpador]
turtles-own[energia]
comiloes-own[direcao melhorPercecao mem]
limpadores-own[qtdResiduos melhorPercecao direcao mem spec] ;Memoria
globals [nAlimento nLNormal nLToxico nDepositos ganhoLN ganhoLT]


to Setup
  clear-all
  Setup-patches
  Setup-turtles
  reset-ticks
end

to Go
  if count limpadores = 0 or count comiloes = 0 or ticks = 10000
  [
    stop
  ]
  morte-agentes
  ifelse limpadoresInteligentes?
  [
    inteligenciaLimpadores
  ]
  [
    moveLimpadores
  ]

  if sentimentos?
  [
    sentimentos
  ]
  ifelse comiloesInteligentes?
  [
    inteligenciaComiloes
  ]
  [
    moveComiloes
  ]
  if comiloesVampiros?
  [
    comiloesVampiros
  ]
  ;
  ifelse reciclagem?
  [
    reciclagem
  ]
  [
    mais-comida
  ]
  tick
end

to Setup-patches
  ask patches with [pcolor = black]
  [
    if random 101 < percLixoNormal
    [
      set pcolor yellow
    ]
  ]
  ask patches with [pcolor = black]
  [
    if random 101 < percLixoToxico
    [
      set pcolor red
    ]
  ]
  ask patches with [pcolor = black]
  [
    if random 101 < percAlimento
    [
      set pcolor green
    ]
  ]
  ask patches with [pcolor = black]
  [
    if count patches with [pcolor = blue ] < depositos
    [
      set pcolor blue
    ]
  ]
  set nAlimento count patches with [pcolor = green]
  set nLNormal count patches with [pcolor = yellow]
  set nLToxico count patches with [pcolor = red]
  set nDepositos 0

  ifelse comiloesMutantes?
  [
    comiloesMutantes
  ]
  [
    set ganhoLT 0.1
    set ganhoLN 0.05
  ]
end

to Setup-turtles

  create-comiloes nComiloes
  [
    set shape "face neutral"
    set color red
  ]

  create-limpadores nLimpadores
  [
    set shape "face neutral"
    set color violet
    set qtdResiduos 0
    set mem 0
    if especializacao?
    [
      set spec one-of [yellow red]
    ]
  ]

  ask turtles
  [
    setxy random-xcor random-ycor
    set energia energiaInicial
    while [pcolor != black]
    [
      setxy random-xcor random-ycor
    ]
  ]


end

to morte-agentes

  ask turtles
  [
    if energia <= 0
    [
      die
    ]
  ]

end

to moveComiloes

  ask comiloes
  [
    if reproducao?
    [
      reproduzir
    ]
    ;Verificação da celula atual.   Se for verde come e ganha energia

    ifelse [pcolor] of patch-here != black
    [
      ifelse [pcolor] of patch-here = green
      [
        set pcolor black
        set energia energia + energiaAlimento
      ]
      [
        ifelse [pcolor] of patch-here = blue
        [
          fd 1
        ]
        [
          ;Se for !=preto e !=verde e !=blue significa que é lixo, logo morre
          die
        ]
      ]
    ]
    ;;;;;;;;;;,Ve primeiro a celula atual e depois as percecoes

    [
      set energia (energia - 1)
      ifelse [pcolor] of patch-ahead 1 != black and [pcolor] of patch-ahead 1 != blue
      [
        ifelse [pcolor] of patch-ahead 1 = green
        [
          fd 1
        ]
        [
          ifelse [pcolor] of patch-ahead 1 = yellow
          [
            set energia energia - (energia * ganhoLN)
            ifelse random 101 < 50
            [
              rt 90
            ]
            [
              lt 90
            ]
          ]
          [
            if [pcolor] of patch-ahead 1 = red
            [


              set energia energia - (energia * ganhoLT)

              ifelse random 101 < 50
              [
                rt 90
              ]
              [
                lt 90
              ]

            ]
          ]
        ]
      ]
      [
        ifelse [pcolor] of patch-left-and-ahead 90 1 != black and [pcolor] of patch-left-and-ahead 90 1 != blue
        [
          ifelse [pcolor] of patch-left-and-ahead 90 1 = green
          [
            lt 90
          ]
          [
            ifelse [pcolor] of patch-left-and-ahead 90 1 = yellow
            [
              set energia energia - (energia * ganhoLN)
              ifelse random 101 < 50
              [
                fd 1
              ]
              [
                rt 90
              ]
            ]
            [
              if [pcolor] of patch-left-and-ahead 90 1 = red
              [
                set energia energia - (energia * ganhoLT)

                ifelse random 101 < 50
                [
                  fd 1
                ]
                [
                  rt 90
                ]

              ]
            ]
          ]
        ]
        [
          ifelse [pcolor] of patch-right-and-ahead 90 1 != black and [pcolor] of patch-right-and-ahead 90 1 != blue
          [
            ifelse [pcolor] of patch-right-and-ahead 90 1 = green
            [
              rt 90
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead 90 1 = yellow
              [
                set energia energia - (energia * ganhoLN)
                ifelse random 101 < 50
                [
                  fd 1
                ]
                [
                  lt 90
                ]
              ]
              [
                if [pcolor] of patch-right-and-ahead 90 1 = red
                [

                  set energia energia - (energia * ganhoLT)

                  ifelse random 101 < 50
                  [
                    fd 1
                  ]
                  [
                    lt 90
                  ]

                ]
              ]
            ]
          ]
          [
            ifelse random 101 < 90 ;Movimentação sem perceçoes, pois se percecionar lixo morre
            [
              fd 1;
            ]
            [
              ifelse random 101 < 50
              [
                lt 90
              ]
              [
                rt 90
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end



to moveLimpadores

  ;Percecionam a celula da frente e a da direita 90º e podem andar para a frente virar 90º para a esquerda ou direita

  ;  limitResiduos
  ask limpadores
  [
    if reproducao?
    [
      reproduzir
    ]
    ifelse qtdResiduos < limitResiduos ;Se o deposito ainda nao tiver cheio
    [
      ;ifelse [pcolor] of patch-here = blue or [pcolor] of patch-here = green

      ;;;;;;;;;;;;Se a celula atual for de cor;;;;;;;;;;;;;;;
      ifelse [pcolor] of patch-here != black
      [
        ifelse [pcolor] of patch-here = blue   ;Se a celula atual for azul
        [
          set energia energia + (10 * qtdResiduos)
          set qtdResiduos 0
          set nDepositos nDepositos + 1
          fd 1
        ]
        [ ;;;;;;;;;;Se a celula atual for verde;;;;;;;;

          ifelse [pcolor] of patch-here = green
          [
            ifelse qtdResiduos < (limitResiduos / 2)
            [
              set energia (energia + energiaAlimento)
              set pcolor black
            ]
            [
              set energia (energia + (energiaAlimento / 2))
              set pcolor black
            ]

          ]
          [
            ifelse especializacao?
            [
              especializacaoLimpadores
            ]
            [
              ;;;;;;;;;;;;; Se a celula atual for amarela;;;;;;;;;;;;
              ifelse [pcolor] of patch-here = yellow
              [
                set qtdResiduos qtdResiduos + 1
                set pcolor black
              ]
              [
                ;;;;;;;;;;;;; Se a celula atual for vermelha;;;;;;;;;;;;
                if [pcolor] of patch-here = red
                [
                  set qtdResiduos qtdResiduos + 2
                  set pcolor black
                ]
              ]
            ]
          ]
        ]
      ]
      [
        ;;;;;;;;;;;Entrando aqui significa que a celula atual é preta, logo vamos verificar as percecoes do agente;;;;;;;;;;;;;;;;;;

        set energia energia - 1 ;Diminui uma unidade pois se a celula atual é preta significa que vai haver um movimento

        ;;;;;;;Percecionar alimento (celula verde);;;;;;;;;;;;;;;;
        ifelse [pcolor] of patch-ahead 1 = green or [pcolor] of patch-right-and-ahead 90 1 = green
        [
          ifelse [pcolor] of patch-ahead 1 = green
          [
            fd 1
          ]
          [
            if [pcolor] of patch-right-and-ahead 90 1 = green
            [
              rt 90;
            ]
          ]
        ]
        [
          ;;;;;;;Percecionar o ninho (celula azul);;;;;;;;;;;;;;;;
          ifelse [pcolor] of patch-ahead 1 = blue or [pcolor] of patch-right-and-ahead 90 1 = blue
          [
            ifelse [pcolor] of patch-ahead 1 = blue
            [
              fd 1
            ]
            [
              if [pcolor] of patch-right-and-ahead 90 1 = blue
              [
                rt 90;
              ]
            ]
          ]
          [
            ifelse especializacao?
            [
              ifelse [pcolor] of patch-ahead 1 = spec or [pcolor] of patch-right-and-ahead 90 1 = spec
              [
                ifelse [pcolor] of patch-ahead 1 = spec
                [
                  fd 1
                ]
                [
                  if [pcolor] of patch-right-and-ahead 90 1 = spec
                  [
                    rt 90
                  ]
                ]
              ]
              [
                ifelse random 101 < 90
                [
                  fd 1
                ]
                [
                  ifelse random 101 < 50
                  [
                    lt 90
                  ]
                  [
                    rt 90
                  ]
                ]
              ]
            ]

            [ ;;;;;;;;;;;;;;;;;Percecionar lixo normal;;;;;;;;;;;;;;;;;;
              ifelse [pcolor] of patch-ahead 1 = yellow or [pcolor] of patch-right-and-ahead 90 1 = yellow
              [
                ifelse [pcolor] of patch-ahead 1 = yellow
                [
                  fd 1
                ]
                [
                  if [pcolor] of patch-right-and-ahead 90 1 = yellow
                  [
                    rt 90
                  ]
                ]
              ]
              [
                ;;;;;;;;;;;;;;;;;Percecionar lixo toxico;;;;;;;;;;;;;;;;;;
                ifelse [pcolor] of patch-ahead 1 = red or [pcolor] of patch-right-and-ahead 90 1 = red
                [
                  ifelse [pcolor] of patch-ahead 1 = red
                  [
                    fd 1
                  ]
                  [
                    if [pcolor] of patch-right-and-ahead 90 1 = red
                    [
                      rt 90
                    ]
                  ]
                ]
                [ ;;;;;;;;;;Caso nao entre em nenhum dos if's anteriores;;;;;;;;;;;;;
                  ;Movimentacao
                  ifelse random 101 < 90
                  [
                    fd 1
                  ]
                  [
                    ifelse random 101 < 50
                    [
                      lt 90
                    ]
                    [
                      rt 90
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;Se o deposito tiver cheio;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                               ;Se a memoria está cheia passamos por cima do lixo???????
    [
      ifelse [pcolor] of patch-here = blue   ;Se a celula atual for azul
      [
        set energia energia + (10 * qtdResiduos)
        set qtdResiduos 0
        set nDepositos nDepositos + 1
        fd 1
      ]
      [   ;verifica-se se a celula é verde
        ifelse [pcolor] of patch-here = green
        [
          set energia energia + (energiaAlimento / 2)
          set pcolor black
        ]
        [  ;Caso contrario verifica-se se alguma das suas percecoes forem azuis
          set energia energia - 1
          ifelse [pcolor] of patch-ahead 1 = blue
          [
            fd 1
          ]
          [
            ifelse [pcolor] of patch-right-and-ahead 90 1 = blue
            [
              rt 90
            ]
            [
              ifelse [pcolor] of patch-ahead 1 = green
              [
                fd 1
              ]
              [
                ifelse [pcolor] of patch-right-and-ahead 90 1 = green
                [
                  rt 90
                ]
                [ ;Movimentacao
                  ifelse random 101 < 90
                  [
                    fd 1
                  ]
                  [
                    ifelse random 101 < 50
                    [
                      lt 90
                    ]
                    [
                      rt 90
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end


to mais-comida

  while [count patches with [pcolor = red] < nLToxico]
      [
        ask one-of patches with [pcolor = black and not any? turtles-here]
        [
          set pcolor red
        ]
  ]
  while [count patches with [pcolor = yellow ] < nLNormal]
    [
      ask one-of patches with [pcolor = black and not any? turtles-here]
      [
        set pcolor yellow
      ]
  ]
  while [count patches with [pcolor = green] < nAlimento]
    [
      ask one-of patches with [pcolor = black and not any? turtles-here]
      [
        set pcolor green
      ]
  ]
end



to inteligenciaLimpadores

  ;Percecionam a celula da frente e a da direita 90º e podem andar para a frente virar 90º para a esquerda ou direita

  ;  limitResiduos
  ask limpadores
  [
    if reproducao?
    [
      reproduzir
    ]
    ifelse qtdResiduos < limitResiduos ;Se o deposito ainda nao tiver cheio
    [
      ;ifelse [pcolor] of patch-here = blue or [pcolor] of patch-here = green

      ;;;;;;;;;;;;Se a celula atual for de cor;;;;;;;;;;;;;;;
      ifelse [pcolor] of patch-here != black
      [


        ifelse [pcolor] of patch-here = blue   ;Se a celula atual for azul
        [
          set energia energia + (10 * qtdResiduos)
          set qtdResiduos 0
          set nDepositos nDepositos + 1
          fd 1
        ]
        [ ;;;;;;;;;;Se a celula atual for verde;;;;;;;;


          ifelse [pcolor] of patch-here = green
          [
            ifelse qtdResiduos < (limitResiduos / 2)
            [
              set energia (energia + energiaAlimento)
              set pcolor black
            ]
            [

              set energia (energia + (energiaAlimento / 2))
              set pcolor black
            ]

          ]
          [
            ifelse especializacao?
            [
              especializacaoLimpadores
            ]
            [
              ;;;;;;;;;;;;; Se a celula atual for amarela;;;;;;;;;;;;
              ifelse [pcolor] of patch-here = yellow
              [
                set qtdResiduos qtdResiduos + 1
                set pcolor black
              ]
              [
                ;;;;;;;;;;;;; Se a celula atual for vermelha;;;;;;;;;;;;
                if [pcolor] of patch-here = red
                [
                  set qtdResiduos qtdResiduos + 1
                  set pcolor black
                ]
              ]
            ]
          ]
        ]
      ]

      [
        ;;;;;;;;;;;Entrando aqui significa que a celula atual é preta, logo vamos verificar as percecoes do agente;;;;;;;;;;;;;;;;;;

        set energia energia - 1 ;Diminui uma unidade pois se a celula atual é preta significa que vai haver um movimento


        ifelse any? neighbors with [pcolor != black]
        [
          set direcao 0
          let x 0
          set melhorPercecao 5
          while [x < 360 and mem = 0]
          [
            ifelse [pcolor] of patch-right-and-ahead x 1 = green
            [
              if melhorPercecao > 1
                [
                  set melhorPercecao 1
                  set direcao x
              ]
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead x 1 = blue and qtdResiduos > 1
              [
                if melhorPercecao > 2
                [
                  set melhorPercecao 2
                  set direcao x
                ]
              ]
              [
                ifelse especializacao?
                [
                  if [pcolor] of patch-right-and-ahead x 1 = spec
                  [
                    if melhorPercecao > 3
                    [
                      set melhorPercecao 3
                      set direcao x
                    ]
                  ]
                ]
                [
                  ifelse [pcolor] of patch-right-and-ahead x 1 = red
                  [
                    if melhorPercecao > 3
                    [
                      set melhorPercecao 3
                      set direcao x
                    ]
                  ]
                  [
                    if [pcolor] of patch-right-and-ahead x 1 = yellow
                    [
                      if melhorPercecao > 4
                      [
                        set melhorPercecao 4
                        set direcao x
                      ]
                    ]
                  ]
                ]
              ]
            ]
            set x (x + 45)
          ]

          ifelse mem = 0
          [
            ifelse direcao = 0
            [
              fd 1
            ]
            [
              right direcao
              set mem 1   ; Se o mem for 0 signfica que analizou o ambiente
            ]
          ]
          [
            fd 1
            set mem 0   ;Caso contrario significa que ja analizou e é a vez de movimentar
          ]
        ]
        [
          ifelse random 101 < 90
          [
            fd 1
          ]
          [
            ifelse random 101 < 50
            [
              lt 90
            ]
            [
              rt 90
            ]
          ]
        ]
      ]
    ]


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;Se o deposito tiver cheio;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                               ;Se a memoria está cheia passamos por cima do lixo???????
    [

      ifelse [pcolor] of patch-here = blue   ;Se a celula atual for azul
      [
        set energia energia + (10 * qtdResiduos)
        set qtdResiduos 0
        set nDepositos nDepositos + 1
        fd 1
      ]
      [   ;verifica-se se a celula é verde
        ifelse [pcolor] of patch-here = green
        [
          set energia energia + (energiaAlimento / 2)
          set pcolor black
        ]
        [  ;Caso contrario verifica-se se alguma das suas percecoes forem azuis
          set energia energia - 1
          ifelse any? neighbors with [pcolor = green] or any? neighbors with [pcolor = blue]
          [

            let x 0
            set melhorPercecao 3
            while [x < 360 and mem = 0]
            [

              ifelse [pcolor] of patch-right-and-ahead x 1 = green
              [
                if melhorPercecao > 1
                [
                  set melhorPercecao 1
                  set direcao x
                ]
              ]
              [
                if [pcolor] of patch-right-and-ahead x 1 = blue
                [
                  if melhorPercecao > 2
                  [
                    set melhorPercecao 2
                    set direcao x
                  ]
                ]

              ]
              set x (x + 45)
            ]
            ifelse mem = 0
            [
              ifelse direcao = 0
              [
                fd 1
              ]
              [
                right direcao
                set mem 1   ; Se o mem for 0 signfica que analizou o ambiente
              ]
            ]
            [
              fd 1
              set mem 0   ;Caso contrario significa que ja analizou e é a vez de movimentar
            ]
          ]

          [
            ifelse random 101 < 90
            [
              fd 1
            ]
            [
              ifelse random 101 < 50
              [
                lt 90
              ]
              [
                rt 90
              ]
            ]
          ]
        ]
      ]
    ]

  ]
end

to especializacaoLimpadores ; copara o patch com a especializacao. Se for igual recolhe, senao ignora.
  ifelse [pcolor] of patch-here = spec and spec = yellow
  [
    set qtdResiduos qtdResiduos + 1
    set pcolor black
  ]
  [
    ifelse [pcolor] of patch-here = spec and spec = red
    [
      set qtdResiduos qtdResiduos + 1
      set pcolor black
    ]
    [
      fd 1
    ]
  ]
end

to sentimentos

  ask turtles
  [
    ifelse energia > (energiaInicial * 2)
    [
      set shape "face happy"
    ]
    [
      ifelse energia >= (energiaInicial * 0.8) and energia <= (energiaInicial * 2)
      [
        set shape "face neutral"
      ]
      [
        if energia < (energiaInicial * 0.8)
        [
          set shape "face sad"
        ]
      ]
    ]
  ]
end

to reproduzir
  if random 101 < 5
  [
    set energia energia / 2
    hatch 1
  ]
end


to inteligenciaComiloes

  ask comiloes
  [
    if reproducao?
    [
      reproduzir
    ]
    ;Verificação da celula atual.   Se for verde come e ganha energia

    ifelse [pcolor] of patch-here != black
    [
      ifelse [pcolor] of patch-here = green
      [
        set pcolor black
        set energia energia + energiaAlimento
      ]
      [
        ifelse [pcolor] of patch-here = blue
        [
          fd 1
        ]
        [
          ;Se for !=preto e !=verde e !=blue significa que é lixo, logo morre
          die
        ]
      ]
    ]
    ;;;;;;;;;;,Ve primeiro a celula atual e depois as percecoes

    [
      set energia (energia - 1)
      ifelse any? neighbors with [pcolor != black] or any? neighbors with [pcolor != blue]
      [
        set direcao 0
        let x 0
        set melhorPercecao 5
        while [x < 360 and mem = 0]
          [
            ifelse [pcolor] of patch-right-and-ahead x 1 = green
            [
              if melhorPercecao > 1
                [
                  set melhorPercecao 1
                  set direcao x
              ]
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead x 1 = black
              [
                if melhorPercecao > 2
                [
                  set melhorPercecao 2
                  set direcao x
                ]
              ]
              [
                ifelse [pcolor] of patch-right-and-ahead x 1 = red
                [

                  set energia energia - (energia * ganhoLT)
                  if melhorPercecao > 3
                  [
                    set melhorPercecao 3
                    set direcao x + 90
                  ]
                ]
                [
                  if [pcolor] of patch-right-and-ahead x 1 = yellow
                  [
                    set energia energia - (energia * ganhoLN)
                    if melhorPercecao > 4
                    [
                      set melhorPercecao 4
                      set direcao x + 90
                    ]
                  ]
                ]

              ]
            ]
            set x (x + 45)
        ]

        ifelse mem = 0
        [
          ifelse direcao = 0
          [
            fd 1
          ]
          [
            right direcao
            if melhorPercecao < 3
            [
              set mem 1   ; Se o mem for 0 signfica que analizou o ambiente
            ]

          ]
        ]
        [
          fd 1
          set mem 0   ;Caso contrario significa que ja analizou e é a vez de movimentar
        ]
      ]
      [
        ifelse random 101 < 90
        [
          fd 1
        ]
        [
          ifelse random 101 < 50
          [
            lt 90
          ]
          [
            rt 90
          ]
        ]
      ]
    ]

  ]

end

to comiloesVampiros

  ask comiloes
  [
    if any? limpadores-on neighbors
    [

      set energia (energia * 2)

      ask one-of limpadores-on neighbors
      [
        set energia energia - (energia * 0.20)
      ]

    ]

  ]


end

to reciclagem
  while [count patches with [pcolor = green or pcolor = red or pcolor = yellow] < nLToxico + nLNormal + nAlimento]
  [
        ask one-of patches with [pcolor = black and not any? turtles-here]
        [
          set pcolor green
        ]
  ]


end


to comiloesMutantes

  set ganhoLT -0.1
  set ganhoLN -0.05

end




@#$#@#$#@
GRAPHICS-WINDOW
210
10
713
514
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
12
50
78
83
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
105
51
168
84
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
11
102
183
135
nComiloes
nComiloes
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
12
147
184
180
nLimpadores
nLimpadores
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
12
190
184
223
energiaInicial
energiaInicial
0
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
11
278
183
311
percLixoNormal
percLixoNormal
0
15
1.0
1
1
NIL
HORIZONTAL

SLIDER
11
322
183
355
percLixoToxico
percLixoToxico
0
15
1.0
1
1
NIL
HORIZONTAL

SLIDER
11
365
183
398
percAlimento
percAlimento
5
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
11
409
183
442
depositos
depositos
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
10
449
182
482
limitResiduos
limitResiduos
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
11
233
183
266
energiaAlimento
energiaAlimento
1
50
25.0
1
1
NIL
HORIZONTAL

MONITOR
727
26
822
71
Nº Limpadores
count limpadores
17
1
11

MONITOR
831
26
914
71
Nº Comiloes
count comiloes
17
1
11

PLOT
728
211
1150
488
Agentes
ticks
agentes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"limpadores" 1.0 0 -8630108 true "" "plot count limpadores"
"comiloes" 1.0 0 -2674135 true "" "plot count comiloes"

MONITOR
924
25
1010
70
Nº Alimento
count patches with [pcolor = green]
17
1
11

MONITOR
725
83
822
128
Nº Lixo Normal
count patches with [pcolor = yellow]
17
1
11

MONITOR
830
83
915
128
Nº Lixo Toxico
count patches with [pcolor = red]
17
1
11

MONITOR
923
83
1010
128
Depositos
nDepositos
17
1
11

SWITCH
1161
221
1351
254
limpadoresInteligentes?
limpadoresInteligentes?
1
1
-1000

SWITCH
1159
359
1286
392
especializacao?
especializacao?
1
1
-1000

MONITOR
828
150
915
195
Limpadores N
count limpadores with [spec = yellow]
17
1
11

MONITOR
923
150
1009
195
Limpadores T
count limpadores with [spec = red]
17
1
11

SWITCH
1160
313
1289
346
sentimentos?
sentimentos?
0
1
-1000

MONITOR
729
150
818
195
Agentes felizes
count turtles with[shape = \"face happy\"]
17
1
11

SWITCH
1160
267
1289
300
reproducao?
reproducao?
0
1
-1000

SWITCH
1161
172
1350
205
comiloesInteligentes?
comiloesInteligentes?
1
1
-1000

SWITCH
1161
128
1338
161
comiloesVampiros?
comiloesVampiros?
1
1
-1000

SWITCH
1159
404
1318
437
comiloesMutantes?
comiloesMutantes?
1
1
-1000

SWITCH
1157
86
1286
119
reciclagem?
reciclagem?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Analise 1 - inteligencias" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reciclagem?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaAlimento">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesInteligentes?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoNormal">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limitResiduos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesMutantes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesVampiros?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="depositos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percAlimento">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoToxico">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limpadoresInteligentes?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sentimentos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="especializacao?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Analise 5 - reproducao" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reciclagem?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaAlimento">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoNormal">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limitResiduos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesMutantes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesVampiros?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="depositos">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percAlimento">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoToxico">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limpadoresInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sentimentos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="especializacao?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Analise 2 - mutantes" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reciclagem?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaAlimento">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoNormal">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limitResiduos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesMutantes?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesVampiros?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="depositos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percAlimento">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoToxico">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limpadoresInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sentimentos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="especializacao?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Analise 4 - especialização" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reciclagem?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaAlimento">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoNormal">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limitResiduos">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesMutantes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesVampiros?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="depositos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percAlimento">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoToxico">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limpadoresInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sentimentos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="especializacao?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Analise 1 - vampiros" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reciclagem?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaAlimento">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoNormal">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limitResiduos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesMutantes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesVampiros?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="15"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="depositos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percAlimento">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoToxico">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limpadoresInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sentimentos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="especializacao?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Analise 2/3 - reciclagem" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reciclagem?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaAlimento">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoNormal">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limitResiduos">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesMutantes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="comiloesVampiros?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="depositos">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percAlimento">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percLixoToxico">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limpadoresInteligentes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sentimentos?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="especializacao?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
