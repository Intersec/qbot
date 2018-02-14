robot.hear /daoud bot/, (chat) ->
 nb = randomInt(1, 4)
 if nb = 1
     text = "C'est lourd"
   else if nb = 2
     text = "C'est de la drague"
   else if nb = 3
     text = "C'est du harcèlement"
   else
     text = "C'est une agression"
 chat.reply text
