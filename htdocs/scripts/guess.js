
function GuessSortname(name)
{
   var first_space

   name=name.replace(/\s+/g," ");
   first_space=name.indexOf(" ");
   if(first_space!=-1)
      name=name.substring(first_space+1,name.length).
         concat(", ",name.substring(0,first_space));
   return name;
}

function GuessCase(string)
{
   var words,i

   string=string.replace(/\s+/g," ").toLowerCase();
   words=string.split(" ");

   for(i=0;i<words.length;i++)
   {
      words[i]=words[i].substring(0,1).toUpperCase().
         concat(words[i].substring(1,words[i].length));
   }

   string=words.join(" ");

   string=string.
      replace(/\sa\s/gi," a ").
      replace(/\san\s/gi," an ").
      replace(/\sthe\s/gi," the ").
      replace(/\sand\s/gi," and ").
      replace(/\sbut\s/gi," but ").
      replace(/\sor\s/gi," or ").
      replace(/\snor\s/gi," nor ").
      replace(/\sas\s/gi," as ").
      replace(/\sat\s/gi," at ").
      replace(/\sby\s/gi," by ").
      replace(/\sfor\s/gi," for ").
      replace(/\sin\s/gi," in ").
      replace(/\sof\s/gi," of ").
      replace(/\son\s/gi," on ").
      replace(/\sto\s/gi," to ").
      replace(/\so'\s/gi," o' ").
      replace(/\s'n'\s/gi," 'n' ").
      replace(/\sn'\s/gi," n' ");

   return string;
}

