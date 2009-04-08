var currentLetter,
    placeList,
    namesDict = ["macNames","firstNames","lastNames"];
    namesDict.macNames = ["apostrophe","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
    namesDict.macNames.apostrophe = "(a'challies|a'phearsain|a'phearsoin|o'Shannaig|o'shenag|o'shennaig)";
    namesDict.macNames.a = "(abe|abee|abin|absolon|achaine|achallies|achan|achane|acharn|achern|acherne|achin|" +
                           "achine|achounich|ada|adaidh|adaim|adam|adame|adams|addam|addame|addie|ade|adie|adoo|afee|affe|affer|affie|aichan|aid|" +
                           "aig|aige|ailein|ailin|ailpein|ain|aindra|aindreis|ainish|ainsh|aiskill|aitchen|ala|alach|alar|alasdair|alastair|" +
                           "alaster|alay|albea|aldonich|aldowie|aldowrie|aldowy|alduie|alear|aleerie|alees|alestar|alestare|alester|alestere|" +
                           "alestir|alestre|alexander|aliece|alinden|alinton|alistair|alister|all|allan|allane|allar|allaster|allay|allestair|" +
                           "allestar|allester|allestyr|alley|allister|allum|alman|almant|almont|alonan|aloney|alonie|alowne|alpain|alpie|alpin|" +
                           "alpine|alpy|alpyne|alshonair|alshoner|alstar|alwraith|alyschandir|amelyne|amhaoir|amlain|anaba|anally|ance|andeoir|" +
                           "andlish|andrew|andrie|andro|andy|ane|angus|anish|ann|annally|ansh|anstalcair|anstalkair|aoidh|aomlin|aonghus|aphie|" +
                           "appersone|ara|ardie|ardle|ardy|aree|arlich|arliche|armick|arorie|arory|arquhar|arra|array|arthur|artnay|artney|" +
                           "asgaill|asgill|asguill|ash|askel|askie|askill|askin|askle|aslan|asland|aslen|aslin|atee|ath|auchin|aughtrie|aughtry|" +
                           "auihlay|aula|aulay|auld|aule|auley|auliffe|aull|aulla|aullay|aully|auselan|auslan|ausland|auslane|auslin|aver|avery|" +
                           "aves|avis|avish|avoy|aw|awis|awishe|awla|awlay|aws|ay|aychin)";
    namesDict.macNames.b = "(ba|bae|bain|baine|baith|bane|bard|bardie|barron|bartny|bathe|baxtar|baxter|bay|bayne|bea|bean|beane|beath|beatha|" +
                           "beathy|bee|behan|beith|ben|beolain|berkny|bertny|beth|betha|bey|bheath|bheatha|bheathain|birney|birnie|birtny|blain|" +
                           "blair|blane|braid|brain|braine|brair|braire|braten|bratney|bratnie|brayan|brayne|breck|breive|brennan|bretnach|" +
                           "bretney|bretnie|bretny|breyane|breyne|briar|brid|bridan|bride|brieve|broom|bryd|bryde|bryne|burie|burney|burnie|byrne)";
    namesDict.macNames.c = "(ca|caa|cabe|cachane|cachie|cachin|cadam|cadame|caddam|caddame|caddim|cadie|cadu|caell|caffe|caffer|cafferty|caffie|" +
                           "caffir|caffrey|cagy|caibe|caichrane|caidh|caig|caige|cail|caill|cain|caincollough|caine|cainsh|cairlich|cairlie|" +
                           "cairly|cairn|caish|caishe|cala|cale|caleb|calim|calister|call|calla|callan|callane|callar|callaster|callay|calley|" +
                           "callie|callien|callion|callister|callman|callome|calloun|callow|callpin|callum|cally|calmain|calman|calme|calmin|" +
                           "calmon|calmont|calpie|calpin|calppin|calpy|calpyne|caluim|calume|calvine|calvyn|calzean|camant|cambil|cambridge|" +
                           "came|camey|camie|camiey|cammell|cammie|cammon|cammond|camon|cance|canch|canchie|candless|candlish|cane|canish|" +
                           "caniss|cann|cannally|cannan|cannel|cannell|cannon|canrig|canrik|cans|canse|cansh|cants|caoidh|cara|carday|cardie|" +
                           "cardney|cardy|cargo|carlach|carley|carlich|carliche|carlie|carlycht|carmick|carmike|carnochan|carquhar|carra|" +
                           "carracher|carres|carron|carson|cartair|carter|carthy|cartnay|cartney|carty|cary|casgill|casguill|cash|caskall|" +
                           "caskel|caskell|caskie|caskil|caskill|caskin|caskle|caskull|caslan|casland|caslane|caslen|caslin|casline|cathail|" +
                           "cathay|cathie|cathy|cauchquharn|caueis|caug|caughan|caughtrie|caughtry|cauish|caul|caula|caulaw|caulay|cauley|" +
                           "caull|cauly|cause|causland|cavat|cavell|cavis|cavish|cavss|caw|cawe|caweis|cawis|cawley|caws|cay|cayne|ceachan|" +
                           "ceachie|ceallaich|ceasag|ceasaig|cellaich|cellair|celler|cenzie|ceol|cersie|cey|chaddy|chaffie|chananaich|chardaidh|" +
                           "chardy|charles|charlie|cheachan|cheachie|cherlich|chesney|cheyne|chlerich|chlery|choiter|chomay|chombeich|chombich|" +
                           "chomich|chonachy|chord|chormaig|chray|christian|christie|christy|chritter|chruimb|chruitar|chruiter|chrummen|" +
                           "chruter|chruytor|chrynnell|chrystal|chrytor|chullach|churteer|chuthais|cill|cisaig|clachan|clachane|clacharty|" +
                           "clacherty|clachlane|clachlene|clae|claffirdy|clagan|clagane|clagnan|claichlane|clain|claine|clairtick|clallane|" +
                           "claman|clamon|clamroch|clan|clanachan|clanaghan|clanahan|clanan|clanaquhen|clandon|clane|clannachan|clannochan|" +
                           "clannochane|clannoquhen|clanochan|clanochane|clanohan|clanoquhen|clansburgh|claran|claren|clarence|clarene|clarens|" +
                           "claring|clarren|clarron|clarsair|clartie|clarty|clary|clatchie|clatchy|clathan|clauchlan|clauchlane|clauchlin|" +
                           "claugan|clave|clawrane|clay|clayne|cleallane|clean|cleane|clearen|clearey|cleary|cleave|cleay|cleche|clees|cleiche|" +
                           "cleilane|cleisch|cleish|cleishe|cleisich|clelan|clellan|clelland|clement|clements|clemont|clen|clenachan|clenaghan|" +
                           "clenaghen|clenahan|clenane|clenden|clendon|cleneghan|clenighan|clennaghan|clennan|clennochan|clennoquhan|clennoquhen|" +
                           "clenoquhan|cleod|cleoyd|clerich|cleriche|clerie|cleron|clery|clese|clester|cleud|cleve|clew|cleys|cliesh|climents|" +
                           "climont|clingan|clinie|clinighan|clinnie|clintoch|clintock|clinton|clirie|cloaud|cloid|cloide|clonachan|clone|cloo|" +
                           "cloor|clorty|clory|closkey|cloud|clour|cloy|cloyd|clucas|clue|clugash|clugass|clugeis|cluie|cluir|cluire|clullich|" +
                           "clumpha|clung|clunochen|clure|clurg|clurich|cluskey|cluskie|clusky|clymond|clymont|clynyne|coag|coage|coaig|coal|" +
                           "coan|coard|coasam|coch|cochran|cock|codruim|codrum|coel|coid|coinnich|coirry|coiseam|cole|coleis|colem|coleman|coll|" +
                           "collea|colleis|collister|colloch|collom|collum|colly|colm|colmain|colman|colme|colmie|colmy|colum|comaidh|comais|" +
                           "comas|comash|comb|combe|comber|combich|combie|combs|come|comes|comey|comiche|comick|comie|comish|comiskey|comok|" +
                           "comtosh|comy|conacher|conachie|conachy|conaghy|conche|concher|conchie|conchy|condach|condachie|condachy|condie|" +
                           "condochie|condoquhy|condy|conechie|conechy|conell|conich|conil|conile|conill|coniquhy|conkey|conl|conlea|connach|" +
                           "connacher|connachie|connaghy|connal|connchye|connechie|connechy|connel|connell|connichie|connil|connill|connochie|" +
                           "connoquhy|connquhy|connyll|conochey|conochie|conoughey|conquhar|conquhie|conquhy|conquy|cooish|cook|cool|corc|corcadail|" +
                           "corcadale|corcadill|cord|cordadill|coren|cork|corkell|corker|corkie|corkil|corkill|corkindale|corkle|corley|cormack|" +
                           "cormaic|cormaig|cormick|cormock|cormok|cornack|cornick|cornock|cornok|corqudill|corquell|corquhedell|corquidall|" +
                           "corquidill|corquidle|corquodale|corquodill|corquydill|corrie|corron|corry|corvie|corwis|cory|cosch|cosh|cosham|" +
                           "coshan|coshen|coshim|coshin|cosker|coskery|coskrie|coskry|cosram|coubray|coubrey|coubrie|couck|coug|couil|couk|" +
                           "couke|coul|coulach|coulagh|coulaghe|coule|coull|coun|courich|court|couyll|cowag|cowan|cowatt|cowbyn|cowell|cowen|" +
                           "cowig|cowil|cowir|cowis|cowl|cowlach|cowle|cowley|cown|cowne|coy|coyle|coynich|cra|crabit|craccan|crach|crachan|" +
                           "crachen|crackan|cracken|crae|craich|craie|craikane|crain|craing|craith|craken|cran|crane|crary|crastyne|crath|cravey|" +
                           "craw|cray|crea|creaddie|creadie|cready|creary|creath|creavie|creavy|creddan|credie|cree|creerie|creery|creich|creiff|" +
                           "creigh|creight|creire|creirie|creitche|creith|crekan|crekane|crendill|crenild|creory|crerie|crery|crevey|crewer|crewir|" +
                           "crie|crime|crimmon|crimmor|crindell|crindill|crindle|crire|cririck|cririe|cristal|criste|cristie|cristin|cristine|" +
                           "criuer|crivag|criver|crobert|crobie|crokane|crom|cron|crone|crore|crorie|crory|croskie|crossan|crotter|crouder|" +
                           "crouther|crow|crowther|croy|cruar|cruimein|cruithein|crum|crumb|crume|crumen|crumie|crundle|crunnell|cryndill|" +
                           "cryndle|crynell|crynill|crynnell|crynnill|cuabain|cuag|cuaig|cuail|cuaill|cualraig|cuaraig|cubben|cubbin|cubbine|" +
                           "cubbing|cubbon|cubein|cubeine|cuben|cubene|cubine|cubyn|cubyne|cucheon|cudden|cudie|cue|cueish|cuffie|cug|cuiag|" +
                           "cuidhean|cuig|cuilam|cuile|cuimrid|cuinn|cuir|cuish|cuishe|cuistan|cuisten|cuistion|cuiston|cuithean|cuithein|cuk|" +
                           "culey|culican|culigan|culigin|culikan|culiken|cullach|cullagh|cullaghe|cullaigh|cullan|cullauch|cullen|culley|" +
                           "culliam|cullie|cullin|cullion|cullo|culloch|cullocht|cullogh|culloh|cullom|cullough|cullum|cully|culzian|cune|" +
                           "cunn|cuoch|cur|curchie|curdie|curdy|cure|curich|curie|currach|curragh|currich|currie|curry|curtain|curthy|cusack|" +
                           "cusker|cutchan|cutchen|cutcheon|cutchion|cuthaig|cuthan|cutheon|cwne|callum)";
    namesDict.macNames.d = "(dade|daid|daniell|david|dermid|diarmid|donachie|donald|donalds|donleavy|donnell|dougall|drain|duff|duffie|dulothe|" +
                           "dairmid|dairmint|danel|daniel|darmid|dearmid|dearmont|dermaid|dermand|derment|dermont|dermot|dermott|dhiarmaid|" +
                           "dhomhnuill|dhonchaidh|dhonnachie|dhugal|dhughaill|diarmond|dill|dimslea|doaniel|dogall|dole|doll|donach|donachy|" +
                           "donagh|donart|donchy|donell|donill|donnach|donnchaidh|donnel|donnill|donnslae|donnyle|donochie|donol|donoll|donough|" +
                           "donquhy|donyll|dool|dormond|douagh|doual|douall|douell|dougal|dougald|doughal|dougle|doul|douny|douwille|douyl|dovall|" +
                           "dovele|doville|dovylle|dowal|dowale|dowall|dowalle|dowele|dowell|dowelle|dowile|dowille|dowilt|dowll|dowylle|doyle|" +
                           "dual|duall|duel|duffee|duffy|dugal|dugald|duhile|dule|dull|duncan|dunlane|dunleavy|dunlewe|dunslea|duoel|duphe|duthie|" +
                           "duwell|duwyl)";
    namesDict.macNames.e = "(eachan|eachern|eachin|eachran|earachar|elfrish|elheran|eoin|eol|erracher|ewan|eachain|eachainn|eachane|eacharin|" +
                           "eacharne|eachearn|eachen|eacheran|eachine|eachnie|eachny|eachren|ealair|ean|eane|eanruig|eantailyeour|earacher|" +
                           "echan|echeny|echern|echerns|echnie|eda|eddie|egie|einzie|eiver|elduff|eleary|eletyn|elfresh|elhatton|elherran|" +
                           "ellar|ellere|elligatt|elpersoun|elrath|elroy|elvain|elveen|elwain|emlinn|enrick|entyre|enzie|eogan|eoghainn|" +
                           "eoghann|eracher|erar|erchar|errocher|esayg|eth|ethe|etterick|ettrick|euchine|euen|euer|euir|eun|eur|eure|evan|" +
                           "evar|even|ever|evin|evine|evoy|ewen|ewer|ewin|ewine|ewing|ewingstoun|ewir|ewn|ewyre)";
    namesDict.macNames.f = "(fadzean|fall|farlane|farquhar|fater|feat|fergus|fie|fadden|faddrik|fade|faden|fadin|fadion|fadrick|fadwyn|" +
                           "fadyean|fadyen|fadyon|fadzan|fadzein|fadzeon|faell|fagan|faid|fail|fait|faitt|faktur|fal|fale|fargus|farlan|" +
                           "farland|farlen|farlin|farling|farquher|farsane|farsne|farson|fate|father|fatridge|fattin|faul|fauld|faull|" +
                           "fayden|fayle|fead|feate|featers|fedden|federan|fedran|fedrice|fee|feeters|fegan|ferchar|ferlane|ferquhair|" +
                           "ferquhare|ferries|ferson|fersoune|fetridge|fey|feyden|feye|fingan|fingon|fingone|finnan|finnen|finnon|fleger|" +
                           "foill|forsoun|forsyth|frederick|frizzel|frizzell|frizzle|fuirigh|fuktor|fuktur|fun|funie|funn|fyall|fydeane|" +
                           "fyngoun)";
    namesDict.macNames.g = "(gaw|geachie|geachin|geoch|ghee|ghie|gilbert|gilchrist|gill|gilledon|gillegowie|gillivantic|gillivour|gillivray|" +
                           "gillonie|gilp|gilroy|gilvernock|gilvra|gilvray|glashan|glasrich|gorrie|gorry|goun|gowan|gown|grath|gregor|" +
                           "greusich|grewar|grime|grory|growther|gruder|gruer|gruther|guaran|guffie|gugan|guire|gaa|gabhawn|gachan|" +
                           "gachand|gacharne|gachen|gachey|gachie|gachyn|gaghen|gaichan|gaithan|gal|gall|gannet|garadh|garaidh|garmorie|" +
                           "garmory|garra|garrow|garva|garvey|garvie|gaskell|gaskill|gauchan|gauchane|gauchin|gaughrin|gaugie|gaukie|" +
                           "gaulay|gavin|gawley|gaychin|ge|geachan|geachen|geachy|geaghy|geak|gechan|gechie|gee|geechan|geever|gehee|" +
                           "geil|georaidh|george|geouch|germorie|geth|gethe|getrick|gettrich|gettrick|geuchie|gey|ghey|ghillefhiondaig|" +
                           "ghilleghuirm|ghittich|ghobhainn|ghoill|ghowin|ghye|gibbon|gibbone|gibboney|gibon|gibonesoun|giboun|gibson|" +
                           "gie|gigh|gilbothan|gilbride|gilcallum|gilchatton|gilchois|gilcreist|gilcrist|gildhui|gilduff|gildui|gile|" +
                           "gilelan|gilevie|gilewe|gilfatrick|gilfatrik|gilfinan|gilfud|gilhosche|giligan|giliver|gilladubh|gillalane|" +
                           "gillanders|gillandras|gillandrew|gillandrish|gillane|gillas|gillavary|gillavery|gillavrach|gillayne|gilldowie|" +
                           "gille|gilleanan|gilleathain|gillebeatha|gillechallum|gillechaluim|gillechattan|gillecoan|gillecongall|" +
                           "gilledow|gilleduf|gilleduibh|gillefatrik|gillefedder|gilleghuirm|gilleglash|gillegrum|gilleis|gillelan|" +
                           "gillelane|gillemartin|gillemertin|gillemhicheil|gillemichael|gillemichel|gillemitchell|gillemithel|gillenan|" +
                           "gilleoin|gilleon|gilleone|gilleoun|gilleoune|gillepartik|gillepatrick|gillepatrik|gillephadrick|gillephadruig|" +
                           "gillequhoan|gillequhoane|gillereach|gillereith|gillereoch|gillery|gillese|gillevary|gillevoray|gillevorie|" +
                           "gillevray|gillewe|gillewey|gillewhome|gillewie|gillewra|gillewray|gillewriche|gillewy|gillewye|gillfhaolain|" +
                           "gillhois|gillibride|gillican|gillichalloum|gillichoan|gillichoane|gilliduffi|gilliegorm|gillies|gilliewie|" +
                           "gillifudricke|gilligain|gilligan|gilligin|gilligowie|gilligowy|gillimichael|gillinnein|gilliondaig|gillip|" +
                           "gilliphatrick|gilliquhome|gillirick|gillis|gillish|gilliue|gillivary|gilliveide|gilliver|gillivoor|gillivraid|" +
                           "gillivrie|gillivry|gilliwie|gillmichell|gillmitchell|gillochoaine|gillogowy|gillolane|gillon|gillony|gillop|" +
                           "gillowray|gilloyne|gillphatrik|gillreavy|gillreick|gillvane|gillvary|gillveray|gillvery|gillvra|gillvray|" +
                           "gillyane|gilmartine|gilmichal|gilmichel|gilmor|gilnew|gilparick|gilphadrick|gilpharick|gilrey|gilroye|gilvane|" +
                           "gilvar|gilvary|gilveil|gilvern|gilvernoel|gilvery|gilvie|gilvory|gilweane|gilwrey|gimpsie|gimpsy|ginnis|girr|" +
                           "giver|givern|glade|gladrie|glagan|glashen|glashin|glassan|glasserig|glassin|glasson|glassrich|glauchlin|" +
                           "glauflin|gleane|gledrie|gleish|glenaghan|glenan|glennon|glew|glone|glugas|goldrick|gomerie|gomery|gonnal|" +
                           "gonnel|gooch|gorie|gorlick|gormick|gormock|gorre|gory|gouan|gougan|goune|govin|gow|gowen|gowne|gowy|gra|" +
                           "grader|grae|grail|grain|granahan|grane|grasaych|grassych|grassycht|grasycht|graw|grayych|greagh|greal|green|" +
                           "gregare|gregur|greigor|greil|greill|greische|greish|gresche|gresich|gressich|gressiche|greusach|greusaich|" +
                           "grevar|grewer|griger|grigor|grigour|grimen|grimmon|grindal|groary|grouther|growder|gruaig|gruar|grudaire|" +
                           "grudder|grundle|grury|gruthar|guaig|guarie|guarrie|gubb|gubbin|guckin|guffey|guffoc|guffock|guffog|guigan|" +
                           "guill|guilvery|guin|guistan|gulican|gumeraitt|gunnion|guoga|gurgh|gurk|gurkich|gy|gybbon|gye|gyll|gyllepatric)";
    namesDict.macNames.h = "(haffie|hardie|hardy|harold|hendrie|hendry|howell|hugh|hutchen|hutcheon|hael|haffey|haffine|hamish|hans|" +
                           "harday|harg|harrie|harrold|harry|harvie|hatton|hay|hee|hendric|henish|henrie|henrik|henry|herlick|herloch|" +
                           "herres|herries|heth|hethrick|hgie|hieson|hilliegowie|hillies|hilmane|hinch|hinzie|hlachlan|hnight|hoiter|" +
                           "homas|homash|homie|honel|honichy|houat|houl|houle|houston|houtton|hpatrick|hquan|hquhan|hray|hrudder|hruder|" +
                           "hrurter|hruter|huat|hucheon|hucheoun|huin|huiston|huitcheon|hulagh|hullie|hutchin|hutchison|hutchon|hutchoun|" +
                           "hyntoys)";
    namesDict.macNames.i = "(ian|ildowie|ilduy|illeriach|ilreach|ilrevie|ilriach|ilvain|ilvora|ilvrae|ilvride|ilwhom|ilwraith|ilzegowie|" +
                           "immey|inally|indeor|indoe|innes|inroy|instalker|intosh|intyre|iock|issac|iver|ivor|iain|ikin|ilaine|ilandick|" +
                           "ilaraith|ilarith|ilbowie|ilbraie|ilbreid|ilbrick|ilbryd|ilbuie|ilchattan|ilchoan|ilchoane|ilchoen|ilchombie|" +
                           "ilchomhghain|ilchomich|ilchomie|ilchomy|ilchreist|ilchrom|ilchrum|ilchrumie|ilcrist|ilday|ildeu|ildeus|ildew|" +
                           "ildonich|ildoui|ildowy|ildue|ilduf|ilduff|ilees|ileish|ilelan|ilendrish|ileollan|ilergan|ilerith|ileur|ilewe|" +
                           "ilfadrich|ilfatrik|ilfun|ilghuie|ilglegane|ilguie|ilguy|ilhaffie|ilhagga|ilhane|ilhaos|ilhatton|ilhauch|ilhaugh|" +
                           "ilhench|ilheran|ilherran|ilhois|ilhoise|ilhose|ilhouse|iliphadrick|ilishe|iliwray|illaine|illandarish|illandick|" +
                           "illayn|illbride|illeain|illechallum|illees|illeese|illeglass|illeish|illeland|illenane|illepatrick|illephadrick|" +
                           "illephedder|illepheder|illephudrick|illereoch|illereoche|illergin|illevorie|illewe|illewie|illfatrick|illfreish|" +
                           "illfrice|illhois|illhos|illhose|illhuy|illichoan|illiduy|illimhier|illiruaidh|illon|illory|illreach|illreave|" +
                           "illrevie|illrick|illvain|illveyan|illvra|illwrick|ilmanus|ilmartine|ilmeane|ilmeine|ilmertin|ilmeyne|ilmichael|" +
                           "ilmichaell|ilmichall|ilmichell|ilmorie|ilmorrow|ilmoun|ilmune|ilmunn|ilna|ilnae|ilnaey|ilneive|ilnew|iloray|" +
                           "iloure|ilpadrick|ilpatrick|ilpedder|ilquham|ilquhan|ilra|ilraich|ilraith|ilravey|ilravie|ilray|ilreath|ilreave|" +
                           "ilrie|ilrith|ilrivich|ilroy|ilroych|iluraick|iluray|ilurick|ilvail|ilvaine|ilvane|ilvar|ilvayne|ilvean|ilveane|" +
                           "ilveen|ilveerie|ilvern|ilvernock|ilvery|ilvian|ilvoray|ilvory|ilvra|ilvrach|ilvraith|ilvray|ilvreed|ilwain|" +
                           "ilwaine|ilweine|ilwham|ilwhannel|ilwra|ilwraithe|ilwrathe|ilwray|ilwrick|ilwrith|immie|inair|inas|inayr|incaird|" +
                           "inchruter|inclerich|inclerie|inclerycht|indeoir|indoer|inechy|ineskair|inesker|inferson|ingvale|inisker|inkaird|" +
                           "inkeard|inlaintaig|inleaster|inleister|inlester|inlister|innesh|inneskar|innesker|inness|innis|innisch|innish|" +
                           "innocater|innon|innowcater|innowcatter|innuer|innugatour|innuier|innyeir|inocader|instokir|instray|instrie|" +
                           "instry|instucker|intagart|intagerit|intailyeour|intargart|intayleor|intaylor|inteer|inthosse|intioch|intire|" +
                           "intoch|intoschecht|intoschie|intoschye|inturner|intyir|intyller|intylor|intyr|inuair|inuar|inuctar|inucter|" +
                           "inuire|inuyer|invaille|invale|invalloch|inville|invine|iosaig|iphie|irvine|isaac|isaak|isack|isaick|isak|iseik|" +
                           "ish|istalkir|ittrick|ivar|iverach|ivirach|iye)";
    namesDict.macNames.j = "(james|jamis|janet|jannet|jarrow|jerrow|jiltroch|jock|jore)";
    namesDict.macNames.k = "(kail|kames|kaskill|kay|keachan|keamish|kean|kechnie|kee|keggie|keith|kellachie|kellaig|kellaigh|kellar|kelloch|" +
                           "kelvie|kendrick|kenrick|kenzie|keochan|kerchar|kerlich|kerracher|kerras|kersey|kessock|kichan|kieson|kiggan|" +
                           "killigan|killop|kim|kimmie|kindlay|kinlay|kinley|kinnell|kinney|kinning|kinnon|kintosh|kinven|kirdy|kissock|" +
                           "knight||k|ka|kaa|kaay|kadam|kadem|kadie|kaggie|kai|kaig|kaige|kaigh|kaill|kain|kainzie|kairlie|kairly|kaiscal|" +
                           "kaiskill|kalar|kale|kalexander|kall|kalla|kallan|kallay|kallister|kalpie|kalpin|kame|kance|kandrew|kane|kanrig|" +
                           "kantoiss|kants|kanyss|kanze|karas|kardie|karlich|kascal|kaskil|kaskin|kau|kaula|kauley|kaw|kawe|kawes|kbayth|" +
                           "kbrid|kcaige|kchonchie|kcline|kconil|kconnell|kcook|kcoul|kcrae|kcrain|kcrow|kcrumb|kculloch|kdowall|ke|keachie|" +
                           "keachy|keag|keand|keandla|keane|keanzie|kearass|keardie|kearlie|kearly|kearrois|kearsie|keaver|keay|kecherane|" +
                           "kechern|kechran|kechrane|kechren|keddey|keddie|kedy|keech|keechan|keeg|keekine|keenan|keesick|keever|keevor" +
                           "|kegg|keich|keig|keihan|keil|kein|keinezie|keinzie|keissik|keithan|keithen|keiver|keiy|kelar|kelbride|keldey|" +
                           "keldowie|kelecan|kelegan|kelein|keleran|kelican|kell|kellaich|kellayr|keller|kellor|kelly|kelpin|kelrae|kelvain|" +
                           "kelvey|kemie|kemmie|kemy|kena|kenabry|kendric|kendrich|kendrie|kendrig|kendry|kenen|keney|kenezie|kenich|kenie|" +
                           "kenmie|kenna|kennah|kennan|kennane|kennay|kenney|kentase|kentyre|kenyee|kenyie|kenzy|keon|keowan|keown|keracher|" +
                           "keracken|keraish|keras|kercher|kerdie|kerichar|kericher|kerley|kerliche|kerlie|kerloch|kermick|kern|kernock|" +
                           "kerral|kerrel|kerricher|kerrin|kerris|kerron|kerrow|kersie|kersy|kesek|kesk|kessack|kessick|kessog|kessogg|" +
                           "keswal|kethan|kethe|kethrick|ketterick|kettrick|keur|keurtain|kever|kevin|kevor|kevors|kew|kewan|kewer|kewin|" +
                           "kewish|kewn|kewnie|kewyne|kewyr|key|keyoche|kfarlen|kghie|kgil|kglesson|khardie|khimy|khonachy|kiachan|kiaran|" +
                           "kiarran|kibbin|kibbon|kick|kiddie|kie|kiech|kiehan|kigg|kildaiye|kildash|kilday|kilferson|kilhaffy|kilhoise|" +
                           "kilican|kilikin|kill|killaig|kille|killeane|killenane|killhose|killiam|killib|killican|killicane|killichane|" +
                           "killichoan|killigane|killigin|killimichael|killip|killmartine|killmichaell|killor|kilmichael|kilmichel|kilmine|" +
                           "kilmon|kilmoun|kilmun|kilmune|kilmurray|kilpatrick|kilquhone|kilrae|kilrea|kilroy|kiltosche|kilvain|kilvane|" +
                           "kilven|kilvie|kilwein|kilweyan|kilwraith|kilwrath|kilwyan|kimmy|kindel|kindew|kindle|kinfarsoun|kinin|kinish|" +
                           "kinla|kinna|kinnay|kinnel|kinnen|kinnes|kinneskar|kinness|kinnie|kinnis|kinnoch|kinoun|kinsagart|kinshe|" +
                           "kinstay|kinstrey|kinstrie|kinstry|kintaggart|kintaylzeor|kintishie|kintoch|kintoche|kintoisch|kintorss|kintyre|" +
                           "kinyie|kinze|kinzie|kiock|kirchan|kirdie|kirsty|kisack|kiseck|kissack|kissek|kissick|kissoch|kistock|kithan|" +
                           "kitterick|kittrick|kiver|kivers|kivirrich|kiynnan|kjames|klagan|klain|klan|klanachen|klanan|klane|klannan|" +
                           "klarain|klawchlane|klawklane|klechreist|klehois|kleiry|klellan|klellane|klemin|klemurray|klen|klenden|klendon|" +
                           "kleod|kleroy|klewain|klewraith|klin|klinnan|klowis|kluire|kmaster|kmillan|kmorran|kmunish|kmurrie|knabe|knach|" +
                           "knacht|knae|knaer|knaight|knair|knaire|knaught|knaughtane|knawcht|knaycht|knayt|kne|kneach|kneale|knedar|knee|" +
                           "kneicht|kneis|kneische|kneishe|knellan|kness|knicht|knie|knilie|knily|knish|knitt|knockater|knocker|knockiter|" +
                           "knokaird|koen|komash|komie|kommie|komy|konald|kondachy|kone|konnell|konochie|kork|korkitill|korkyll|kornock|" +
                           "kornok|kouchane|koull|koun|kowean|kowen|kowie|kowin|kowle|kowloch|kowloche|kowne|kownne|kowyne|kperson|kphaill|" +
                           "kpharsone|kqueane|kquyne|kra|krachin|krae|kraith|kraken|kray|krayth|kreath|kree|kreiche|krekane|krenald|krenele|" +
                           "krie|kritchy|krory|kuen|kuenn|kuerdy|kuffie|kuinn|kuir|kuish|kukan|kulagh|kulican|kullie|kulloch|kullouch|kune|" +
                           "kuntosche|kunuchie|kure|kurerdy|kurkull|kurrich|kury|kush|kusick|kussack|kwarrathy|kwatt|kwhinney|kwilliam|ky|" +
                           "kye|kygo|kym|kymmie|kynich|kynioyss|kynnair|kynnay|kynnayr|kynnell|kynnie|kyntagart|kyntaggart|kyntalyhur|" +
                           "kyntoich|kyntossche|kyntoys|kyrnele)";
    namesDict.macNames.l = "(lachlan|lae|lagan|laghlan|laine|lairish|lamond|lardie|lardy|laren|larty|laverty|laws|lea|lean|leay|lehose|" +
                           "leish|leister|lennan|leod|lergain|lerie|leverty|lewis|lintock|lise|liver|lucas|lugash|lulich|lure|lymont|" +
                           "labhrain|labhruinn|lachan|lachie|lachlainn|lachlane|lachlin|lackie|laerigh|laerike|laertigh|laffertie|lafferty|" +
                           "lagain|lagane|lagen|laggan|laggen|lagine|laglan|laglen|lagone|laiman|lain|laine|lairen|lairtie|lalan|lalland|" +
                           "lallen|lammie|lamon|lamont|lamroch|lanachan|lanaghan|lanaghen|landsborough|lane|lannachen|lanochen|lanoquhen|" +
                           "laomuinm|laran|larin|laring|lartie|lartych|latchie|latchy|lauchan|lauchlan|lauchlane|lauchleine|lauchlen|" +
                           "lauchlin|lauchrie|laugas|laughan|laughlan|laughland|laughlane|laughlin|lauren|laurent|laurin|laurine|lavor|" +
                           "lawchtlane|lawhorn|lawmane|lawran|lawrin|lawrine|lay|layne|leand|leane|leannaghain|lear|leary|leash|leaver|" +
                           "leerie|lees|leesh|leever|lefrish|lehoan|leich|lein|lelan|leland|lelane|lelann|lelen|lellan|lelland|lellane|" +
                           "leman|lemme|lemon|lemond|len|lenaghan|lenane|lenden|lendon|lene|lenechen|lenochan|lentick|leoad|leoid|leot|" +
                           "leougas|leran|lergan|lerich|lern|leron|leroy|lese|less|letchie|leud|leur|lewain|lewd|ley|lglesson|limont|lin|" +
                           "linden|linein|linnen|lintoch|lish|liss|llauchland|lochlainn|lochlin|lockie|lode|loed|loghlin|loid|loir|lokie|" +
                           "lolan|lolane|lonachin|lonvie|loon|loor|lorn|louchlan|loud|lougas|loughlin|louis|louvie|low|lowe|lowkas|loy|" +
                           "loyde|lroy|lucais|lucase|luckie|lucky|lude|lugaish|lugane|lugas|lugeis|lugers|luggan|lugish|luguis|luir|luke|" +
                           "lulaghe|lulaich|lulli|lullich|lullick|lumfa|lumpha|lung|lur|lurg|luskey|luskie|lusky|lwannell|lwhannel|lyn|" +
                           "lyndon)";
    namesDict.macNames.m = "(manus|martin|master|math|maurice|menzies|michael|millan|minn|monies|morran|munn|murchie|murchy|murdo|murdoch|" +
                           "murray|murrich|mutrie||maghnuis|magister|magnus|mahon|main|maines|mainess|mains|malduff|man|manamy|manaway|" +
                           "manes|manis|mann|mannas|mannes|mannus|mark|marquis|marten|martun|martyne|mathon|mayne|meachie|mean|means|" +
                           "meechan|meekan|meeken|meekin|meeking|meikan|mein|meinn|men|menamie|menamin|menemie|menemy|menigall|mertein|" +
                           "mertene|mertin|mhannis|mhaolain|mhathain|mhourich|mhuireadhaigh|mhuirich|mhuirrich|mhurchaidh|michan|micheil|" +
                           "michell|michie|mickan|micken|mickin|micking|migatour|mikan|miken|milane|milland|millen|millin|millon|min|" +
                           "mina|mine|minne|minnies|minnis|mitchel|mitchell|moil|molan|molane|molland|monagle|monnies|moran|morane|" +
                           "mordoch|moreland|moren|morice|mories|morin|morine|moris|morland|moroquhy|morrane|morrin|moryn|moryne|" +
                           "mowtrie|muckater|muiredhaigh|muiredhuigh|muirigh|mukrich|mulan|mulane|mullan|mullen|mullin|mullon|mulron|" +
                           "munagle|muncater|muncatter|mune|mungatour|murachy|murchaidh|murchou|murd|murdon|murdy|muredig|murich|murphy|" +
                           "murquhe|murquhie|murre|murree|murriche|murrie|murrin|murry|murrycht|murrye|murtchie|murtery|murtie|murtrie|" +
                           "mury|mychel|mychele|mylan|myllan|myllane|myn|myne|mynneis)";
    namesDict.macNames.n = "(nab|nair|namell|naughton|nayer|nee|neil|neilage|neiledge|neilly|neish|neur|ney|nider|nie|nish|niter|niven|" +
                           "nuir|nuyer|nabb|nachdan|nacht|nachtan|nachtane|nachtin|nachton|nae|naght|naghtane|naghten|naicht|naichtane|" +
                           "naight|nail|naill|nairn|nait|nakaird|nale|nally|namaoile|namil|namill|naoimhin|naois|naoise|nap|nar|nare|" +
                           "narin|natt|naucater|nauch|nauche|nauchtan|nauchtane|nauchton|naught|naughtan|naughten|nauth|nauton|nay|" +
                           "nayair|nayr|nayre|nea|neacail|neacain|neacden|neachdainn|neachden|neadair|neal|neale|neall|near|necaird|" +
                           "nedair|nedar|nedyr|neel|neelie|neer|nees|neice|neid|neigh|neight|neill|neille|neillie|neir|neis|neische|" +
                           "neiss|neit|neiving|nekard|nele|nelly|nely|nesche|neskar|nesker|ness|nett|nettar|nevin|newer|neyll|nial|" +
                           "nicail|niccoll|nichol|nichole|nicholl|nicht|nickle|nicol|nicoll|nidder|niel|nielie|niff|night|nikord|" +
                           "nillie|nily|nische|nitt|nivaine|noah|noaise|noble|nocaird|noder|nokaird|nokard|nokerd|nokord|nomiolle|" +
                           "nomoille|norcard|norton|nougard|nowcater|nowcatter|noyar|noyare|noyiar|nucadair|nucater|nucator|nucatter|" +
                           "nuctar|nuer|nuicator|nuire|nure|nutt|nvyr|nychol|nychole|nycholl|nysche)";
    namesDict.macNames.o = "(|omie|omish|onie|oran|oull|ourlic|owen|owl|obyn|ochtery|ochtrie|ochtry|odrum|oisein|olaine|oldonich|oleane|" +
                           "olmichaell|ologhe|olonie|olony|olphatrick|olrig|omelyne|onachie|onachy|onchie|ondochie|ondoquhy|onechy|onee|" +
                           "oneill|onele|onhale|onill|onlay|onochie|onohie|orkill|ormack|orquidill|orquodale|oseanag|osenage|osennag|" +
                           "osham|oshennag|oshenog|ostrich|ostrick|oual|ouat|ouhir|oul|oulie|oulric|oulroy|ourich|owan|owat|owis|owlache)";
    namesDict.macNames.p = "(patrick|petrie|phadden|phater|phedran|phedron|pheidiran|pherson|phillip|phorich|phun|padane|paden|paid|paill|" +
                           "parlan|parland|parlane|parlin|partick|patre|paul|paule|pawle|pearson|peeters|person|persone|personn|peter|" +
                           "petir|petre|petri|phadan|phaddion|phade|phadein|phaden|phadraig|phadrick|phadrig|phadrik|phadruck|phadruig|" +
                           "phadryk|phadzen|phael|phaell|phaid|phaide|phaidein|phaiden|phaidin|phail|phaile|phaill|phait|phale|pharheline|" +
                           "pharick|pharlain|pharlane|pharson|phate|phatrick|phatricke|phatryk|phaul|phaull|phayll|pheadair|pheadarain|" +
                           "phearson|pheat|phedar|pheddair|pheddrin|phedearain|phederan|phedrein|phee|pheidearain|pheidran|pheidron|" +
                           "phell|phersen|phersone|phete|phial|phie|phiel|philib|philip|philipps|phingone|phoid|phune|phuney|phunie|" +
                           "phunn|phuny|phyden|pilips)";
    namesDict.macNames.q = "(qha|qhardies|qharter|qherter|qua|quaben|quade|quaid|quain|quaker|qualter|quan|quarie|quarrane|quarrey|" +
                           "quarter|quat|quater|quatter|quattie|quatty|quay|quaynes|quckian|que|quean|queane|quee|queeban|queen|queeney|" +
                           "queenie|quein|queine|queir|queiston|quen|quene|questen|queston|queyn|queyne|quhae|quhalter|quhan|quhannil|" +
                           "quharrane|quharrie|quharry|quhartoune|quhat|quhatti|quhattie|quheen|quhen|quhenn|quhenne|quhenzie|quheritie|" +
                           "quheyne|quhine|quhinny|quhinze|quhir|quhirertie|quhirirtie|quhirrie|quhirtir|quhirtour|quhirtoure|quhoire|" +
                           "quhollastar|quhonale|quhonyle|quhore|quhorie|quhorre|quhorter|quhoull|quhriter|quhyn|quhyne|quhynze|quibben|" +
                           "quibbon|quiben|quid|quie|quien|quikan|quilkan|quilliam|quiltroch|quin|quine|quinne|quinnes|quiod|quirter|" +
                           "quistin|quiston|quithean|quitheane|quithen|quorcadaill|quore|quorie|quorn|quorne|quorquhordell|quorquodale|" +
                           "quorquordill|quorrie|qurrie|quyre|qwaker|quaire|quarrie|quartie|quey|quhirr|quire|quistan|quisten|quoid)";
    namesDict.macNames.r = "(rad|rah|raht|raill|railt|rain|raine|raing|ralte|ranal|ranald|randal|randall|randell|ranich|ranie|rankein|" +
                           "rankine|ranking|rankyne|rannal|rannald|rau|raurie|ravey|raw|ray|rayne|re|rea|readie|ready|rearie|reary|" +
                           "reath|reay|redie|ree|reekie|reiche|reil|reill|reirie|reith|renald|renold|rerie|reth|reull|revey|revie|rey|" +
                           "reynald|reynold|reynolds|riche|richie|rie|rikie|rimmon|rindle|rinnell|rinnyl|ririck|riridh|ririe|ritchey|" +
                           "ritchy|rither|robe|roberts|robi|robin|roderick|roe|roithrich|ronald|ronall|rone|rotherick|rourie|row|rowat|" +
                           "rowatt|roy|royre|royree|royri|ruairidh|ruar|ruaraidh|ruary|rudder|rudrie|ruidhri|rurry|ruter|ryche|rynald|" +
                           "rynall|ryndill|rynell|rynild|rypert|ryrie|ra|rach|rae|raild|raith|rankin|rath|ritchie|rob|robb|robbie|" +
                           "robert|robie|rorie|rory|ruer|rurie|rury)";
    namesDict.macNames.s = "(shannachan|shimes|simon|sorley|sporran|swan|sween|swen|symon|sagart|sata|sayde|scamble|scilling|setree|" +
                           "seveney|sherry|shille|shimidh|shimie|shimmie|shirie|shirrie|shuibhne|skellie|skelly|skimming|sloy|soirle|" +
                           "sorle|sorlet|sorlie|sorll|sorlle|sorrill|sorrle|souarl|staker|stalker|steven|stokker|suain|suin|swain|" +
                           "swaine|swane|swanney|sweyne|swigan|swiggan|swyde|swyne)";
    namesDict.macNames.t = "(taggart|tary|tause|tavish|tear|thomas|tier|tire|taevis|tagart|taggard|taggate|taggert|taggit|taldrach|" +
                           "taldridge|taldroch|talzyr|tamhais|tarlach|tarlich|tarmayt|taveis|tawisch|tawys|teer|teir|ter|tere|terlach|" +
                           "teyr|thamais|thamhais|thavish|thearlaich|thom|thomaidh|thomais|thome|thomie|thorcadail|thorcuill|thurkill|" +
                           "toiche|tomais|torquedil|torquil|toschy|toshy|turk|tyr|tyre)";
    namesDict.macNames.u = "(ulric|ure|ualraig|ualtair|uaraig|ubein|ubin|ubine|uidhir|uilam|uilleim|uir|uirigh|uish|uiston|ulagh|ulaghe|" +
                           "ullie|ulloch|ulrich|ulrick|ulrig|une|urchie|urchy|urich)";
    namesDict.macNames.v = "(vinie|vinnie|virrich|virriche|virrist|vitie|vittae|vittie|voerich|vorchie|voreis|voreiss|voreist|vorich|" +
                           "voriche|voris|vorish|vorist|vorrich|vourich|vretny|vrettny|vurarthie|vurarthy|vurchie|vurirch|vuririch|" +
                           "vurist|vurrich|vurriche|vurrish|vain|vaine|vale|vane|vannan|vannel|vararthy|vararty|varraich|varrais|" +
                           "varrich|varrish|varrist|varthie|vat|vater|vaxter|vay|veane|veay|vee|veigh|veirrich|venish|vennie|verrathie|" +
                           "vicker|vie|villie|vail|vanish|varish|veagh|vean|vey|vicar|vinish|vurich|vurie)";
    namesDict.macNames.w = "(wade|waltir|warie|warish|wat|water|watt|watte|watter|wattir|watty|wean|weane|weeny|werarthe|werarthie|wete|" +
                           "wha|whae|whan|whaneall|whanell|whanle|whanlie|whannall|whanne|whannel|whannil|whanrall|wharrie|whaugh|whaw|" +
                           "wheir|whey|whin|whinn|whinney|whinnie|whir|whire|whirrie|whirtour|whiston|whonnell|whorter|whrurter|whunye|" +
                           "why|whynie|whyrter|wiccar|wiggan|williame|williams|willie|winney|wirrich|wirriche|wirter|withean|withy|" +
                           "worthie|wrarthie|wray|wrerdie|wurchie|wurie|wyllie|walrick|walter|wattie|whannell|whirr|whirter|william)";
    namesDict.macNames.x = "";
    namesDict.macNames.y = "(ye|yewin|yllecrist|ylory|ylroy|ylroye|ylveine|ynniel|ynstalker|ynthosche|ynthose|yntoch|yntoisch|yntyre|" +
                           "ynwiss|yowin|ysaac|ysac|yuir|ywene)";
    namesDict.macNames.z = "";
    namesDict.firstNames = [];
    namesDict.firstNames = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
    jQuery.each(namesDict.firstNames, function(i) {
        currentLetter = this;
        namesDict.firstNames[currentLetter] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14];
        jQuery.each(namesDict.firstNames[currentLetter], function(j) {
            namesDict.firstNames[currentLetter][j] = "";
        });
    });
    namesDict.firstNames.a[2] = "(ai|al)";
    namesDict.firstNames.a[3] = "(abe|ace|ada|ade|adi|aja|alf|ali|ami|amy|ana|ann|ara|ari|art|asa|ava|avi|ayo)";
    namesDict.firstNames.a[4] = "(abby|abel|abra|adah|adam|adan|aden|adia|adin|adm.|agda|ahab|aida|aila|aina|aine|aino|ajax|ajay|ajit|akio|" +
                                "alba|alda|aldo|alec|alek|alex|alia|alla|ally|alma|alok|alon|alta|alun|alva|alys|amb.|amee|amie|amir|amit|amon|amos|" +
                                "amya|anat|anca|andy|anil|anja|anju|anka|anke|anna|anne|anya|aqua|aram|arch|ares|aria|aric|arik|aris|arlo|arly|armi|" +
                                "arne|arno|aron|arti|arun|arvo|åsa|åse|asha|ashe|asia|asma|atom|avia|avie|avis|axel|ayah|ayla|azra|azro|azul|akon|alan)";
    namesDict.firstNames.a[5] = "(aanya|aaron|abasi|abbey|abbie|abbot|abdul|abner|abram|abril|acela|achim|adair|adão|addie|adela|adele|adell|adina|" +
                                "adira|adlai|adler|adley|admon|adolf|adria|aedan|aegle|aerin|aeron|aeryn|aeson|afsha|afton|agnes|ahmad|ahmed|ahmya|" +
                                "aidan|aiden|ailsa|aimee|aisha|ajani|akeem|akela|akina|akira|akito|akiva|aksel|alain|alana|alane|alani|alban|albin|" +
                                "albus|alcee|alden|aldis|aleah|aleen|alena|alene|aleta|alexa|alexi|alfie|aliah|alice|alida|alika|aliki|alina|aline|" +
                                "alisa|aliya|aliza|alize|allan|allen|allie|allyn|alohi|alois|alora|alpha|alpin|altea|alter|altha|alton|alura|alvah|" +
                                "alvar|alvia|alvie|alvin|alvis|alwyn|alyce|alysa|alyse|amadi|amado|amaia|amaka|amana|amani|amara|amari|amasa|amata|" +
                                "amaya|amber|amias|amina|amira|amity|amiya|ammie|ammon|amory|anahi|anali|anara|anaya|andon|andra|andre|aneem|angel|" +
                                "angie|angus|anika|anisa|anita|aniya|annie|annis|anouk|ansel|anson|anthi|anton|anwen|aoife|apple|april|arati|arden|" +
                                "ardis|areli|arely|ariah|ariel|arild|arjun|arlan|arlen|arley|arlie|arlin|arlis|armen|armin|arnav|arrie|arron|arrow|" +
                                "artem|artie|artis|artur|arvel|arvid|arvil|arvin|arwen|aryan|asani|ashby|asher|ashli|ashly|ashok|aslan|aspen|aster|" +
                                "astor|asuka|atara|atlas|atlee|auden|audie|audra|audry|aurea|autry|avery|aviva|avril|awnan|ayaka|ayana|aydan|ayden|" +
                                "aydin|aylee|aylin|aziza|azuka)";
    namesDict.firstNames.a[6] = "(a'mari|abdiel|abilee|acacia|acacio|acadia|achebe|adalee|adalia|adalyn|addien|adelia|adella|adelle|adelyn|aderyn|" +
                                "aditya|adolfo|adolph|adonis|adreen|adrian|adriel|adrien|adryan|aelinn|aeneas|aerith|aeysha|afonso|agatha|agueda|" +
                                "agurys|ahijah|ahlica|aidenn|aidric|ailbhe|aileen|ailish|ailith|airyck|aislin|aislyn|aiyana|akilah|alaina|alanis|" +
                                "alanna|alaric|alayna|albany|albert|albina|aldric|alecia|aleena|aleida|alesha|alesia|aletha|alexei|alexia|alexis|" +
                                "alexus|alexys|alford|alfred|aliana|alicia|alijah|alirah|alisha|alison|alissa|alivia|aliyah|allene|alline|allure|" +
                                "almeda|almeta|almira|alonso|alonza|alonzo|altair|althea|alvaro|alvena|alvera|alvina|alycia|alysha|alysia|alyson|" +
                                "alyssa|alyvia|amabel|amachi|amador|amadou|amalia|amalie|amanda|amaris|amelia|amelie|amerie|ameris|amiyah|amparo|" +
                                "anabel|anahid|anaïs|anakin|ananda|anders|andrea|andrei|andres|andrew|andria|angela|angelo|anibal|anikah|anissa|" +
                                "anitra|aniyah|anjali|anneke|anneli|annika|annora|anselm|ansley|anthea|antone|antony|antwan|antwon|aolani|apollo|" +
                                "aquila|arafel|aramis|arandu|archer|archie|ardell|ardith|aretha|ariana|ariane|ariela|arilyn|arisha|arissa|arista|" +
                                "arkady|arleen|arlene|arleth|arline|armand|armani|armida|armond|arnaud|arnold|arther|arthur|arturo|arvind|aryana|" +
                                "asante|ashely|ashlee|ashley|ashlie|ashlyn|ashton|ashtyn|asmara|aspynn|asriel|astrid|athena|athlyn|aubree|aubrey|" +
                                "aubrie|audrey|audrie|august|aurora|aurore|austen|austin|auston|austyn|autumn|avalon|avalyn|averie|averil|avital|" +
                                "awilda|axelle|ayanda|ayanna|ayelet|azalea|azalia|azarel|azaria|azriel)";
    namesDict.firstNames.a[7] = "(aagraha|aaliyah|aariyeh|abagail|abelard|abigail|abigale|abilene|abraham|absalom|absalon|adaline|adalynn|addison|" +
                                "addisyn|addyson|adelard|adelina|adeline|admiral|adriana|adriane|aemilia|afsaneh|agathon|agustin|aidanne|ainsley|" +
                                "aisling|aislinn|aiyanna|alabama|aladdin|alannah|alarice|alberic|alberta|alberto|alcaeus|alessia|alessio|alethea|" +
                                "alexian|alexina|alexios|aleydis|alfonso|alfonzo|alfreda|alfredo|alibeth|alienor|allamea|allegra|alliree|allison|" +
                                "allisyn|allorah|allyson|allyssa|alondra|alpheus|alverta|amadeus|amarion|amberly|ambrose|amelina|america|americo|" +
                                "amidala|ananias|anatole|anatoly|andelyn|andreas|andreia|andrine|angeles|angelia|angelie|angelle|aniylah|annabel|" +
                                "annalee|annamae|annelie|annelle|annetta|annette|anousha|anselmo|anthony|antione|antipas|antoine|antonia|antonin|" +
                                "antonio|araceli|aracely|aragorn|arcadia|arcadio|ardella|ariadne|arianna|ariella|arielle|arienne|ariston|armando|" +
                                "arnaldo|arnoldo|arnulfo|artemas|artemis|arvilla|aryanna|asashia|ashanti|ashlynn|assunta|asteria|astoria|atílio|" +
                                "atlanta|atleigh|atticus|auberon|audrina|augusta|aurelia|aurelie|aurelio|aveline|averick|averley|avianna|avigail|" +
                                "avonlea|azahara|azaryah|azucena)";
    namesDict.firstNames.a[8] = "(aaryanna|abbigail|abdullah|abhishek|abigayle|abriella|abrielle|achilles|ackerley|adelaida|adelaide|adelbert|" +
                                "adolphus|adrianna|adrianne|adrienne|aerolynn|agustina|akiryana|alasdair|alastair|albertha|aletheia|algernon|aliandra|" +
                                "alistair|aloysius|alphaeus|alphonse|alphonso|amandine|amefleur|amethyst|ana-lisa|anabelle|anaëlle|analilia|anatolia|" +
                                "anderson|angelica|angelina|angeline|angelise|angelita|anjelica|annabell|annalisa|annalise|annelies|annelise|annmarie|" +
                                "anoushka|antigone|antonina|antonios|antonius|anugraha|aquilina|arabella|araminta|aranzazu|ashleigh|assumpta|athenais|" +
                                "aubriana|audrieka|augustas|augusten|augustus|aurelian|aurelien|aurelius|avrielle)";
    namesDict.firstNames.a[9] = "(aberforth|adalberto|agamemnon|aishwarya|albertine|alejandra|alejandro|alexander|alexandra|alexandre|alexandro|" +
                                "amarantha|amaryllis|amberlynn|anacletus|anastacio|anastasia|andersonn|androcles|andromeda|angelique|anjanette|" +
                                "annabella|annabelle|annaliese|annamarie|anneliese|annemarie|antonella|antonetta|antonette|aoibheann|apollonia|" +
                                "apostolos|archibald|aristides|aristotle|artemisia|astrophel|athanasia|aubrielle|augustine)";
    namesDict.firstNames.a[10] = "(abbiegayle|adetokunbo|alejhandra|aleksandra|alessandra|alessandro|alexandrea|alexandria|alexandros|alexzander|" +
                                "altagracia|ambassador|amberosity|anastasios|anastasius|anna-lucia|anne-marie|antoinette|antonietta|archimedes|" +
                                "athanasios|auryestela)";
    namesDict.firstNames.a[11] = "(alejandrina|allurarayne)";
    namesDict.firstNames.b[2] = "(bo)";
    namesDict.firstNames.b[3] = "(bay|baz|ben|bly|bob|br.|bud)";
    namesDict.firstNames.b[4] = "(barb|bart|baya|bayo|bear|beau|beck|bell|bert|bess|beth|bill|birk|blas|blue|boaz|bode|bond|boyd|brad|bram|brea|bree|" +
                                "bret|bria|bron|bryn|buck|burl|burn|burt|buzz)";
    namesDict.firstNames.b[5] = "(baden|baeli|baird|baker|balin|bambi|banjo|barak|baron|baron|barry|basia|basil|basim|basma|beata|becky|béla|belen|" +
                                "bella|belle|belva|benno|benny|berit|bernt|berry|berta|beryl|betsy|bette|betty|bevan|bijou|bilal|billy|bindu|birch|" +
                                "birna|bjorn|blade|blair|blake|blane|blaze|bliss|bobbi|bobby|boden|bodie|bonny|boris|bowen|boyce|brady|brant|brent|" +
                                "brett|brian|briar|brice|brien|brier|brisa|brita|britt|brock|brody|bronx|brook|brown|bruce|bruno|bryan|bryce|brynn|" +
                                "bryon|bubba|buddy|buffy|bulah|burke|butch|byron)";
    namesDict.firstNames.b[6] = "(bailee|bailey|bakari|bannon|barack|baraka|barbie|barbra|barker|barney|barron|bartek|barton|baruch|bascom|bashir|" +
                                "baxman|baxter|bayard|baylee|belina|benita|benito|bennet|bennie|benoit|benson|bently|benton|beriah|bernie|bertha|" +
                                "berthe|bertie|berton|besnik|bessie|bethan|bethel|betrys|bettie|bettye|beulah|bianca|billie|billye|birdie|birger|" +
                                "birgit|bishop|bishop|bjarne|bladen|blaine|blaise|blanca|blanch|blayze|blithe|blythe|bobbie|bobbye|bohdan|bonita|" +
                                "bonnie|booker|bosten|boston|bowman|braden|bradly|bradyn|brandi|brandt|brandy|branna|brayan|breana|breann|breeze|" +
                                "brenda|brenna|brenyn|briana|bridie|briggs|brigid|briley|briony|brison|britni|britta|brnss.|brodee|broder|brodie|" +
                                "brogan|brooke|brooks|bryana|bryant|brycen|bryden|brylee|brynja|bryony|bryson|buddie|buford|bunnie|burley|burton|buster)";
    namesDict.firstNames.b[7] = "(babette|baldwin|barbara|barclay|barnaby|barnard|barrett|basilio|bastien|beatrix|beatriz|beaulah|beckett|beckham|" +
                                "bedelia|belinda|bellamy|bennett|bentley|berkley|bernard|bernice|bernita|bertram|bethany|bettina|beverly|billana|" +
                                "blakely|blanche|blossom|bluford|bogumil|boudica|bozeman|bracken|bradley|braeden|braedin|braedon|braedyn|braelyn|" +
                                "braiden|brandan|brandee|branden|brandie|brandon|brandyn|brannon|branson|branwen|braulio|braxton|brayden|braydon|" +
                                "braylon|breanna|breanne|brecken|breckin|breckyn|brendan|brenden|brendon|brennan|brennen|brennon|brenton|breonna|" +
                                "brianna|brianne|bridger|bridget|briella|brielle|brigham|brinley|brionna|bristol|britany|britney|brittni|brittny|" +
                                "britton|bronson|bronwen|bronwyn|brother|bryanna|brynlee|buckley|burgess|burnell|burnice)";
    namesDict.firstNames.b[8] = "(barnabas|baroness|bayleigh|beatrice|belarius|benedict|benedito|benjamin|berenice|berkeley|bernardo|berneice|bernhard|" +
                                "berniece|berthold|bertrand|beverlee|beverley|beyoncé|birgitta|blakelyn|bradford|brannock|bridgett|brigette|brighton|" +
                                "brigitta|brigitte|briseïs|brittani|brittany|brittney|brooklyn|brouklyn|brunilda|bryleigh|brynnley|burdette)";
    namesDict.firstNames.b[9] = "(balthazar|balvinder|bathsheba|bellarosa|bellatrix|bernadine|bethannie|bre'aujee|breehanna|bridgette|brittanie|" +
                                "broderick|bronislaw|brooklynn)";
    namesDict.firstNames.b[10] = "(beauregard|bellefleur|bernadette|bernardine|bienvenido|blodeuwedd|bree'undra)";
    namesDict.firstNames.b[11] = "(bartholomew|bénédicte|brookelynne)";
    namesDict.firstNames.c[3] = "(cab|cal|che|coy|cpo)";
    namesDict.firstNames.c[4] = "(cade|cael|cain|cale|cali|cara|cari|carl|cary|case|cash|cate|cato|ceil|chad|chaz|cher|chet|chip|cian|ciro|clay|clem|" +
                                "cleo|clio|cloe|coby|coco|cody|col.|cole|colm|colt|cora|cori|cory|coty|cpl.|cpt.|crew|cris|cruz|curt|cyra)";
    namesDict.firstNames.c[5] = "(cabot|caden|cadyn|cairo|caleb|calen|calix|calla|cally|calum|camas|cameo|candi|candy|cappy|capt.|caren|carey|carie|" +
                                "carla|carli|carlo|carly|carma|carol|caron|carri|caryl|caryn|carys|casey|casia|casie|cason|caten|cathi|cathy|catie|" +
                                "cayla|ceara|cecil|cedar|celia|cerys|cesar|chace|chadd|chaim|chan.|chana|chani|chase|chava|chaya|cheaa|cheri|chevy|" +
                                "chima|china|chloe|chris|chuck|chyna|ciara|cielo|ciena|ciera|cinda|cindi|cindy|clair|clara|clare|clark|claud|claus|" +
                                "cleon|cleta|cleve|cliff|clint|clive|cloud|cloyd|clyde|cmdr.|codey|codie|cohen|colby|coley|colin|conan|conor|coral|" +
                                "corby|corey|corin|cosme|cosmo|count|cowan|craig|crash|creda|creed|crews|croix|cynan|cyndi|cyril|cyrus)";
    namesDict.firstNames.c[6] = "(caddie|caelan|caesar|caiden|cailyn|cainan|caitee|calder|calico|callan|callie|callum|calvin|camden|camdyn|camila|" +
                                "camilo|camren|camrin|camron|camryn|canaan|candis|candra|cannon|canton|canyon|carden|caress|carina|carisa|carlee|" +
                                "carley|carlie|carlos|carmel|carmen|carole|carrie|carrol|carryn|carson|carter|carver|carwyn|caspar|casper|cassia|" +
                                "cassie|cassio|cathal|cathey|cathie|catina|catrin|cayden|caylee|caylen|cayley|cecile|cecily|cedric|celina|celine|" +
                                "cesare|chaiza|chance|chanda|chanel|charis|charla|charly|chaska|chelsi|chenoa|cherie|cherri|cherry|cheryl|chiara|" +
                                "chiron|chloey|chunda|ciaran|cicely|cicero|cierra|claira|claire|clancy|claren|claude|claudy|cleora|cletus|cliona|" +
                                "clover|clovis|cntss.|colden|coleen|collin|colman|colson|colten|colter|coltin|colton|colwyn|conall|conley|conner|" +
                                "connie|connor|conrad|conroy|conway|cooper|copper|corban|corbin|corder|cordia|cordie|corene|corina|corine|cormac|" +
                                "corrie|cortez|corwin|cosima|cosimo|coster|costin|creola|crissy|cristy|cronan|csilla|cullen|curran|curtis|cutler|" +
                                "cynara|cypher)";
    namesDict.firstNames.c[7] = "(cadence|cadogan|caedmon|caetano|caihong|caillou|caitlin|caitlyn|caitria|caleigh|calista|cambria|camelia|cameron|" +
                                "camilla|camille|camillo|candace|candice|candida|candido|caoimhe|caprice|captain|cardiff|caridad|carissa|carleen|" +
                                "carlene|carlota|carlton|carlyle|carmela|carmelo|carmina|carmine|carnell|carolee|carolyn|carroll|carsten|casimer|" +
                                "casimir|caspian|cassidy|cassius|cathryn|catrina|caydran|cayenne|cecelia|cecilia|cecilie|cecilio|cedrick|celenia|" +
                                "celeste|challen|chandra|chandry|channer|chantal|chantel|chapln.|charity|charlee|charles|charley|charlie|charsey|" +
                                "chasity|chaucer|chayton|chellis|chelsea|chelsee|chelsey|chelsie|cherise|cherish|cherith|cheryle|chesley|chesney|" +
                                "chester|chihiro|chloris|chrissy|christa|christi|christy|cillian|ciprian|citlali|citrine|clarice|clarine|clarion|" +
                                "clarisa|clarity|claudia|claudie|claudio|clayten|clayton|clellan|clemens|clement|clemmie|clifton|clinton|clodagh|" +
                                "coleman|colette|colleen|collier|colonel|columba|connell|connery|copland|coralie|corazon|corbett|cordell|corelia|" +
                                "coretta|corinna|corinne|corliss|cornell|corrine|cortney|cosette|cosmina|coulter|craigan|crayton|crispin|crispus|" +
                                "cristal|cristin|crystal|currier|curtiss|cynthia|cyprian|cyrille)";
    namesDict.firstNames.c[8] = "(caitlann|caitlynn|calandra|calantha|calanthe|callahan|calleigh|calliope|callisto|camellia|camillia|campbell|" +
                                "carleton|carlisle|carlotta|carmella|carolann|carolina|caroline|carolynn|carrigan|casandra|casanova|cassilda|catalina|" +
                                "catarina|caterina|cathleen|cathrine|catriona|chadrick|chadwick|champion|chandell|chandler|chanelle|channing|chaplain|" +
                                "charisma|charissa|charisse|charleen|charlene|charline|charlize|charvala|chastity|chauncey|chestina|cheyanne|cheyenne|" +
                                "chiarina|chiquita|christal|christel|christen|christie|christin|christof|christos|chrystal|cimarron|cinnamon|citlalli|" +
                                "clarance|clarence|claribel|clarinda|clarissa|clarisse|claudine|claudius|clematis|clemency|clemente|cleophas|clifford|" +
                                "cliodhna|clotilde|collette|columbus|concetta|connolly|constant|consuela|consuelo|coolidge|coppelia|coraline|cordelia|" +
                                "cornelia|cornelio|corporal|corrigan|cortland|countess|courtlyn|courtney|crawford|cresence|cressida|crighton|cristian|" +
                                "cristina|crockett)";
    namesDict.firstNames.c[9] = "(caledonia|carmelita|cassandra|cassandre|catharine|catherine|celestina|celestine|celestino|chantelle|chantilly|" +
                                "charlotte|charmaine|charnette|christeen|christene|christian|christina|christine|christmas|claiborne|claudette|" +
                                "cleopatra|cleveland|clothilde|commander|constance|constanza|corabelle|corisande|cornelius|cristobal|cristofer)";
    namesDict.firstNames.c[10] = "(candelario|carrington|chancellor|chancellor|chardonnay|charilette|charleston|charolette|christabel|christiana|" +
                                "christiane|christophe|chrysantha|cinderella|clarabelle|clementina|clementine|concepcion|constantin|cristopher|cuauhtemoc)";
    namesDict.firstNames.c[11] = "(cecelia-rae|charlesnika|charminique|christoffer|christopher|connecticut|constantine)";
    namesDict.firstNames.c[12] = "(clytemnestra|constantinos)";
    namesDict.firstNames.d[3] = "(dag|dan|dax|dee|del|dex|dia|doc|don|dov|dr.)";
    namesDict.firstNames.d[4] = "(dale|daly|dana|dane|dara|dash|dave|davy|dawn|daya|dean|dean|debi|deja|dell|demi|dena|deon|dian|dick|dicy|dina|dink|" +
                                "dino|dion|dirk|disa|diya|dock|dona|donn|dora|dori|dory|doug|dove|drew|drs.|duff|duke|duke|dyan)";
    namesDict.firstNames.d[5] = "(d'nai|daeja|dafna|dafne|dagny|daija|daisy|dalee|dalia|damon|danae|dania|danna|danny|dante|danya|darbi|darby|darci|" +
                                "darcy|daren|daria|darin|dario|darla|daron|daryl|dasia|davey|david|davie|davin|davis|davon|dawna|dayal|dayna|deana|" +
                                "deane|deann|debbi|debby|debra|dedra|deena|deion|dejah|delia|della|delma|delta|denis|denny|derek|deric|derik|deron|" +
                                "deuce|devan|deven|devin|devon|devra|devyn|dewey|diana|diane|diann|diara|diego|dilip|dilys|dimos|dinah|dineo|diogo|" +
                                "divya|dixie|dixon|dodie|dolly|donal|donna|donny|donta|donte|doran|dorin|doris|dorit|doron|dovie|doyle|draco|drake|" +
                                "duane|dugan|dulce|dusti|dusty|dutch|dwain|dwane|dwyer|dylan|dylen|dylon)";
    namesDict.firstNames.d[6] = "(daelyn|dagmar|dahlia|daichi|daisha|dakari|dakota|dalila|dallan|dallas|dallin|dalton|dameon|damian|damien|damion|" +
                                "damita|danara|dandre|danial|danica|daniel|danika|danila|danilo|danita|dannie|daphna|daphne|daquan|darbie|darcie|" +
                                "darell|darian|darien|darion|darius|darold|darrel|darren|darrin|darron|darryl|darwin|daryle|daunte|daveth|davian|" +
                                "davina|davion|dawson|daxton|dayana|dayton|deacon|deanna|deanne|deasia|debbie|debbra|debora|debrah|declan|dedric|" +
                                "deedee|deepak|deidra|deidre|dejuan|delano|delina|delisa|delmar|delmas|delmer|delois|delpha|delton|delvan|delvin|" +
                                "demond|denali|deneen|denham|denice|denisa|denise|dennie|dennis|denton|denver|denzel|denzil|deonte|dequan|dereck|" +
                                "derick|dermot|dervla|derwin|deshae|dessie|destin|destry|detlef|detlev|devlin|dewitt|dexter|deylan|dezzie|dianey|" +
                                "dianna|dianne|dickie|dickon|didier|diello|diesel|dieter|dillan|dillon|dimple|dinesh|dionne|dionte|divine|django|" +
                                "djimon|dobbin|dollie|donald|donato|donell|donita|donnie|dontae|donver|dorcas|doreen|dorene|dorian|dorine|dorman|" +
                                "dorris|dorsey|dortha|dorthy|dottie|dougal|dougie|dragos|draken|draper|draven|dublin|dudley|dulcia|dulcie|duncan|" +
                                "dustin|dwaine|dwayne|dwight|dyllan|dyllon)";
    namesDict.firstNames.d[7] = "(daciana|daisuke|dakotah|damaris|damiana|danelle|danette|dangelo|daniela|darleen|darlene|darline|darnell|darragh|" +
                                "darrell|darreth|darrian|darrick|darrien|darrion|darrius|darshan|dashawn|daveney|davette|davonte|deandre|deborah|" +
                                "dedrick|deeanna|deirdre|delaney|delbert|delfina|delight|delilah|delores|deloris|delphia|demarco|demario|dempsey|" +
                                "denholm|denisse|deondre|deontae|deontay|derrell|derrick|deshaun|deshawn|desirae|desirea|desiree|desmond|despina|" +
                                "destany|destini|destiny|devanie|devante|devinne|devonta|devonte|dewayne|diamond|diantha|diggory|dilbert|dillard|" +
                                "dillion|dimitra|dimitri|dinitia|dohosan|dolores|doloris|dolphus|domenic|dominga|domingo|dominic|dominik|donaldo|" +
                                "donavan|donavon|donnell|donovan|dorathy|doretha|dorinda|dorotha|dorothy|douglas|dresden|dunstan|durward|durwood|" +
                                "duwayne|dy-anne)";
    namesDict.firstNames.d[8] = "(damarion|daniella|danielle|danyelle|dashiell|datryann|dayanara|deangelo|december|delphina|delphine|demarcus|demarion|" +
                                "demetria|demetris|dennison|desabela|destinee|destiney|devontae|diarmuid|dietrich|dimitris|dionisio|domenica|domenick|" +
                                "domenico|domicela|dominica|dominick|dominque|donnelly|dorothea|douglass|dragomir|drucilla|drusilla|dulciana|dulcinea|" +
                                "dumisani)";
    namesDict.firstNames.d[9] = "(dayshanet|delphinia|demetrice|demetrius|desdemona|desiderio|dickinson|dimitrios|dominique|domonique|donatella)";
    namesDict.firstNames.d[10] = "(dulcibella)";
    namesDict.firstNames.d[11] = "(diamondnique)";
    namesDict.firstNames.e[2] = "(ed)";
    namesDict.firstNames.e[3] = "(ean|ebb|eda|edd|eli|emi|ena|era|eva|eve)";
    namesDict.firstNames.e[4] = "(earl|ebba|eben|echo|edda|eddy|eden|edge|edie|edna|egan|egil|egon|ehud|eiel|eino|elam|elan|elba|elda|elia|elin|elio|" +
                                "elis|elke|ella|elle|elma|elmo|elna|elon|eloy|elsa|else|elta|elva|elza|emet|emil|emma|emmy|enid|enos|ens.|enya|enzo|" +
                                "eoin|eric|erik|erin|eris|erma|erna|eron|eryn|esai|esha|esli|esme|esta|etha|etta|eula|euna|eura|evan|ever|evie|evon|" +
                                "ewan|exie|ezra)";
    namesDict.firstNames.e[5] = "(eames|eamon|earle|early|eboni|ebony|eddie|edgar|edina|edith|edmar|edric|edrie|edsel|edwin|edyth|effie|efren|einar|" +
                                "elana|elden|eldon|elena|eleni|eleri|elgar|elgin|eliah|eliam|elian|elias|elida|eliel|elihu|elina|eline|eliot|elisa|" +
                                "elise|eliya|eliza|elkan|ellen|ellie|ellis|ellyn|elmer|elois|elora|elroy|elsie|elton|elvia|elvie|elvin|elvis|elwin|" +
                                "elwyn|elyse|elzie|ember|embry|emeka|emely|emery|emile|emily|emlyn|emmet|emmie|emmit|emory|emrys|ender|ennis|enoch|" +
                                "enola|eowyn|erica|erich|erick|erika|erion|ernie|ernst|errol|ervin|erwin|eskil|espen|essie|estel|ester|ethan|ethel|" +
                                "ethen|ethna|ethne|ethyl|etter|ettie|eulah|evans|evert|evora|ewald|ewell|ewing|eyana|ezell)";
    namesDict.firstNames.e[6] = "(eamonn|earlie|easter|easton|edison|edmond|edmund|edward|edwina|edythe|efraim|efrain|eileen|eilidh|eirlys|eithne|" +
                                "eladio|elaina|elaine|elanor|elayne|elbert|eldora|eldred|elease|electa|elenor|eliana|eliane|elijah|elinor|eliora|" +
                                "eliseo|elisha|eliska|elissa|ellery|elliot|elmira|elmore|elnora|elodie|eloisa|eloise|elvera|elvira|elwood|elyssa|" +
                                "emalee|emelia|emelie|emeric|emilee|emilia|emilie|emilio|emmett|emmitt|enapay|endrit|eneida|enjoli|enrico|ensign|" +
                                "eoghan|ephron|eragon|erasmo|eriana|ericka|erlene|erling|ernest|estela|estell|esther|euclid|eudora|eugene|eunice|" +
                                "evadne|evalyn|evelia|evelin|evelyn|everly|evette|evolet|evonne)";
    namesDict.firstNames.e[7] = "(earlene|earline|earnest|eastman|edgardo|edmonia|edoardo|eduardo|edwardo|éilís|eilonwy|eleanor|eleazar|electra|" +
                                "elektra|elenora|elfrida|eliarys|eliezer|elinore|ellamae|elliott|ellison|ellwood|elouise|elsbeth|elspeth|emanuel|" +
                                "emeline|emerald|emerson|emmalee|emmarie|emogene|enrique|ephraim|erasmus|erastus|erlinda|ernesto|erskine|esmeray|" +
                                "essence|esteban|estella|estelle|estevan|ethelyn|etienne|eugenia|eugenie|eugenio|eulalia|eulalie|eusebio|eustace|" +
                                "evalina|evander|evdokia|evelina|eveline|evelyne|evening|everard|everest|everett|everley|ezekiel)";
    namesDict.firstNames.e[8] = "(ebenezer|edelmira|edgerton|eibhlín|eldridge|eleanora|eleanore|elfrieda|elisabet|elisavet|elisheba|elisheva|ellorial|" +
                                "elyannah|emanuele|emiliano|emmajean|emmaline|emmanuel|emmelina|emmeline|emmerson|emmersyn|endymion|epifanio|erendira|" +
                                "estefani|estefany|estember|estrella|eternity|ethelene|euphemia|evanesca|evanthia|everardo|everette|ezequiel)";
    namesDict.firstNames.e[9] = "(efthimios|eglantine|ekaterina|ekaterini|elisabeth|elizabeth|ellington|ellsworth|enriqueta|ernestina|ernestine|" +
                                "esmeralda|esperanza|estefania|evangelos|everleigh)";
    namesDict.firstNames.e[10] = "(earnestine|elizabella|elizabelle|emmanuelle|ermengarde|evangelina|evangeline)";
    namesDict.firstNames.f[3] = "(fae|fay|fia|flo|fox|foy|fr.)";
    namesDict.firstNames.f[4] = "(fate|fawn|faye|femi|fern|fife|fifi|finn|fion|flem|flor|floy|ford|fran|frau|fred)";
    namesDict.firstNames.f[5] = "(fabio|fairy|faith|faiza|falco|fanny|farid|faron|felix|femke|ferne|ffion|fidel|finis|fiona|fionn|fiora|fleta|fleur|" +
                                "flint|floyd|flynn|foley|fonda|fotis|frank|franz|freda|fredy|freja|freya|friar|frida|fritz|frost)";
    namesDict.firstNames.f[6] = "(fabian|fabien|faisal|fallon|fannie|farida|fariji|farrah|father|fatima|felice|felipa|felipe|felton|fergus|fermin|" +
                                "ferrin|ferris|finbar|finian|finlay|finley|finola|fintan|fisher|flavia|flavio|florin|forbes|forest|foster|fotini|" +
                                "franco|fraser|freddy|freeda|freema|freida|frieda|furman)";
    namesDict.firstNames.f[7] = "(fabiana|fabiola|fabrice|fairfax|fairlie|fairuza|farrell|farrier|feather|felecia|felicia|felisha|fenella|fenisia|" +
                                "fennell|fernand|filippo|finnian|firenze|florene|florian|florida|florine|florrie|flossie|forrest|frances|francis|" +
                                "frankie|frannie|frasier|frazier|freddie|fredric|freeman)";
    namesDict.firstNames.f[8] = "(fabienne|fabriana|fabricio|fabrizio|fairamay|fantasia|faulkner|faustine|faustino|federico|felicita|felicity|ferguson|" +
                                "fernanda|fernando|fielding|filomena|finnegan|fiorenza|flannery|fletcher|florence|forester|foxglove|francine|franklin|" +
                                "franklyn|frederic|fredrick)";
    namesDict.firstNames.f[9] = "(ferdinand|fionnuala|florencia|florencio|forrester|fortunato|francesca|francesco|francisca|francisco|françois|" +
                                "francoise|franziska|frederica|frederick|friedrich)";
    namesDict.firstNames.f[10] = "(florentino|franchesca|francheska)";
    namesDict.firstNames.f[12] = "(frèdèrique)";
    namesDict.firstNames.g[3] = "(gia|gil|gus|guy)";
    namesDict.firstNames.g[4] = "(gabe|gael|gage|gaia|gail|gala|gale|garo|gary|gaye|gen.|gena|gene|geri|ghia|gian|gigi|gina|gino|glen|glyn|gov.|gray|" +
                                "greg|grey|gust|gwen|gwyn)";
    namesDict.firstNames.g[5] = "(gabbi|gabby|gaige|galen|garry|garth|gates|gatha|gaven|gavin|gavyn|gayla|gayle|geary|geeta|gemma|genie|georg|gerda|" +
                                "gerri|gerry|giada|giana|gilad|gilda|giles|gilia|ginny|glenn|glory|glynn|golda|gopal|goran|gower|grace|grady|grant|" +
                                "green|greer|gregg|greig|greta|grier|guido|gypsy)";
    namesDict.firstNames.g[6] = "(gabino|gaelen|gaines|galina|ganesh|gannon|gareth|garett|garnet|garold|garret|gaspar|gaston|gavino|gawain|gaylon|" +
                                "gaynor|gehrig|genaro|geneva|gentry|george|gerald|gerard|german|gerold|gerrit|gertie|gerwyn|gianna|gianni|gibson|" +
                                "gideon|gidget|gilles|ginger|gisela|gisele|giulia|giulio|gladys|glenda|glenna|glinda|gloria|glover|glynda|glynis|" +
                                "golden|goldia|goldie|gordon|graça|gracen|gracie|gracyn|graden|graeme|graham|grania|grasia|gratia|grayce|grayer|" +
                                "grazia|grecia|gregor|gretel|grifin|grover|gudrun|gunnar|gunner|gussie|gustav|gwenel)";
    namesDict.firstNames.g[7] = "(gabriel|gaetano|galilea|galileo|gardner|garland|garnett|garrett|garrick|gaspard|gayatri|gaylord|gaynell|general|" +
                                "general|genesis|genevra|gennadi|gennaro|georges|georgia|georgie|geraldo|geralyn|gerardo|gerhard|gershon|gervase|" +
                                "giacomo|giannes|gilbert|gillian|ginevra|giorgio|giovani|gisella|giselle|gladyce|glendon|glennie|godfrey|gonzalo|" +
                                "goretti|graeden|graelie|graesha|grainne|grayden|graydon|grayson|gregory|greyson|griffin|grissom|gryphon|gunther|" +
                                "gustave|gustavo|gwyneth|gwynyth)";
    namesDict.firstNames.g[8] = "(gabriela|gamaliel|garfield|garrison|genoveva|geoffrey|georgene|georgina|georgine|georgios|germaine|geronimo|" +
                                "gertrude|gilberto|gildardo|gintaras|giorgina|giovanna|giovanni|giovanny|gisselle|giuliana|giuseppe|gottlieb|governor|" +
                                "gracelyn|graciana|graciela|gratiana|greenlee|greggory|gregoria|gregorio|gretchen|griffith|griselda|griselle|guiseppe|" +
                                "gulliver|gurpreet|gwynneth)";
    namesDict.firstNames.g[9] = "(gabriella|gabrielle|galadriel|gavriella|gearldine|genevieve|georgette|georgiana|geraldine|giancarlo|gianpaolo|" +
                                "glendakay|glodybeth|gracelynn|gracionna|granville|graziella|guadalupe|guillaume|guillermo|guinevere|gwendolen|gwendolyn)";
    namesDict.firstNames.g[0] = "(georgellen|georgianna|gianfranco|guillermin)";
    namesDict.firstNames.g[1] = "(guillermina)";
    namesDict.firstNames.h[3] = "(hal|han)";
    namesDict.firstNames.h[4] = "(haia|hale|hali|hana|hank|hans|hart|hawk|herb|hero|hiro|holt|hope|hoyt|huey|hugh|hugo)";
    namesDict.firstNames.h[5] = "(haana|habib|haden|hades|haely|halen|haley|halia|halie|halle|hamid|hamza|handy|hanna|hardy|harry|haven|haydn|hayes|" +
                                "hazel|hazle|heart|heath|heber|hedda|heidi|heidy|heike|heinz|helen|helga|helge|henri|henry|herta|hideo|hilda|hilma|" +
                                "hinto|hiram|hodge|hogan|holli|holly|homer|honey|honor|horst|hosea|hulda|hyman|hyrum)";
    namesDict.firstNames.h[6] = "(hadley|haelee|haidee|haiden|hailee|hailey|hailie|hakeem|halima|halina|halley|hallie|halona|hamish|hampus|hannah|" +
                                "hannes|hansel|harald|harish|harlan|harlen|harley|harlow|harmon|harold|harper|harris|harvey|hassan|hassie|hatten|" +
                                "hattie|haydee|hayden|haylee|hayley|haylie|heaven|hector|hedwig|helena|helene|hellen|helmer|henrik|henson|herman|" +
                                "hermes|hermia|hermon|hernan|hertha|hesper|hester|hestia|hettie|hideki|hilary|hildur|hillel|hilton|hirsch|hjalte|" +
                                "hobart|hobert|holden|hollie|hollis|homero|honora|hooper|hoover|horace|howard|howell|hristo|hubert|hudson|hughes|" +
                                "hunter|hurley|huston|hutton|huxley)";
    namesDict.firstNames.h[7] = "(hadiyah|hadrian|haleigh|halston|harding|harland|harlene|harmony|harriet|hartley|haskell|hatcher|havilah|hayward|" +
                                "haywood|heather|heloise|hendrik|hendrix|herbert|hermann|hermina|hermine|hershel|hilario|hilbert|hildred|hillard|" +
                                "hillary|hiroshi|hitoshi|holland|honoria|horacio|horatio|houston|humbert)";
    namesDict.firstNames.h[8] = "(hadassah|hallsten|hamilton|hannibal|harriett|harriman|harrison|hayleigh|hazelynn|henrique|herminia|herminio|" +
                                "hermione|herschel|hezekiah|hilliard|hinckley|hipolito|honorée|honorius|hortense|hrothgar|humberto|humphrey|hyacinth)";
    namesDict.firstNames.h[9] = "(hannelore|harriette|hawthorne|henderson|henrietta|henriette|hephzibah|heriberto|hildegard|holliston|hortencia|" +
                                "hortensia|hutchison)";
    namesDict.firstNames.h[0] = "(hatshepsut|heathcliff|hermelinda|hildegarde)";
    namesDict.firstNames.i[2] = "(io)";
    namesDict.firstNames.i[3] = "(ian|icy|ida|ike|ila|ima|ina|ion|ira|isa|iva|ivo|ivy)";
    namesDict.firstNames.i[4] = "(iago|icie|ifan|igor|ilan|ilsa|ines|inez|inga|inge|ingo|iola|iole|iona|ione|iris|irma|isai|iser|isis|isla|isom|itai|" +
                                "ivah|ivan|ivey|ivor|ixia)";
    namesDict.firstNames.i[5] = "(ianto|idell|idony|idris|iesha|ilana|ilene|ilian|ilias|ilona|imani|inara|india|indie|inger|inigo|inira|irena|irene|" +
                                "irina|irini|irvin|irwin|isaac|isaak|isela|isiah|isley|isora|issac|italy|itzel|ivana|ivory|iyana|izora)";
    namesDict.firstNames.i[6] = "(ianthe|ichiro|idella|ignatz|ikaika|ilaria|ileana|iliana|imanol|imelda|imogen|inanna|indigo|indira|ingrid|ioanna|" +
                                "irelyn|irving|isabel|isaiah|isaias|isamar|iseult|ishani|ishara|isidro|ismael|ismail|ismene|isobel|isolde|isolyn|" +
                                "israel|istvan|italí|ivette|ivonne|iyanna|izaiah|izetta)";
    namesDict.firstNames.i[7] = "(ibrahim|ichabod|ignacio|igraine|imogene|indiana|ioannis|ireland|isabeau|isabela|isabell|isabeth|isadora|isadore|" +
                                "isannah|ishmael|isidore|ivanhoe)";
    namesDict.firstNames.i[8] = "(idabelle|ignatius|immanuel|ingeborg|iolanthe|isabella|isabelle|israella|ivelisse|izabella|izabelle)";
    namesDict.firstNames.i[9] = "(iphigenia)";
    namesDict.firstNames.j[2] = "(jc|jo)";
    namesDict.firstNames.j[3] = "(jan|jax|jay|jed|jem|jim|job|joe|jon|joy)";
    namesDict.firstNames.j[4] = "(jace|jack|jaco|jada|jade|jael|jago|jair|jake|jali|jami|jana|jane|jann|jase|jaya|jean|jeff|jena|jens|jere|jeri|jess|" +
                                "jett|jexi|jiei|jill|jiri|jiro|joah|joan|joar|jodi|jody|joel|joey|john|joni|jory|josh|joss|jove|juan|judd|jude|judi|" +
                                "judy|juli|juma|juna|june|juno)";
    namesDict.firstNames.j[5] = "(jaana|jabez|jacek|jacey|jacky|jacob|jaden|jadis|jadon|jadyn|jaece|jafar|jahir|jaida|jaima|jaime|jairo|jakob|jalen|" +
                                "jalon|jalyn|jamal|jamar|jamel|james|jamey|jamia|jamie|jamil|jamin|jamir|jamya|janae|janay|janel|janet|janie|janis|" +
                                "janko|janna|janus|jared|jarem|jaren|jaret|jarod|jarom|jaron|jasen|jason|javen|javon|jaxen|jaxon|jaxyn|jayce|jayda|" +
                                "jayde|jayla|jayme|jayna|jayne|jeana|jeane|jemma|jency|jenna|jenny|jerad|jered|jerel|jeret|jerod|jerri|jerry|jeryl|" +
                                "jerzy|jessa|jesse|jessi|jessy|jesus|jetta|jevon|jewel|jimmy|joana|joann|joão|jodee|jodie|joela|joely|johan|joiya|" +
                                "jolie|jomar|jonah|jonas|jonna|jonty|jordy|joren|jorge|jorja|josé|josef|josie|jovan|jovie|joyce|juana|jubal|judah|" +
                                "judge|judge|judie|judit|jules|julia|julie|julio|junia|juraj|justo|juwan)";
    namesDict.firstNames.j[6] = "(jabari|jackie|jaclyn|jacobo|jacoby|jacque|jacqui|jaeden|jaelyn|jagger|jaheem|jaheim|jahiem|jaiden|jaidyn|jailyn|" +
                                "jaimie|jakobe|jalana|jaleel|jalisa|jalynn|jamaal|jamari|jamila|jammie|janana|janeen|janell|janiah|janice|janine|" +
                                "janiya|janney|jannie|jános|jansen|janson|japera|japhet|jaqlyn|jaquan|jaquez|jarred|jarres|jarret|jarrod|jarvis|" +
                                "jasmin|jasmyn|jasper|javier|javion|jaxson|jaycee|jayden|jaydin|jaydon|jaylan|jaylee|jaylen|jaylin|jaylon|jaylyn|" +
                                "jayson|jayvon|jazlyn|jazmin|jazmyn|jeanie|jeanna|jeanne|jeevan|jeffry|jelani|jemada|jemima|jemuel|jenaye|jeneva|" +
                                "jenner|jennie|jenoah|jensen|jerald|jeramy|jeremy|jeriah|jerold|jerome|jeromy|jerrie|jerrod|jesica|jesika|jesper|" +
                                "jessie|jessye|jesusa|jethro|jettie|jewell|jimena|jimmie|jinger|joanie|joanna|joanne|joelle|joetta|johana|johann|" +
                                "johnie|johnna|johnny|jolene|joliet|jolyon|jonina|jonnie|jordan|jorden|jordin|jordon|jordyn|josefa|joseph|joshua|" +
                                "josiah|joslyn|jossie|josué|jovani|jovano|jovany|jovita|judiah|judith|judson|judstn|julian|julien|juliet|julius|" +
                                "juneau|junior|junius|jurgen|justen|justin|juston|justus|justyn)";
    namesDict.firstNames.j[7] = "(jacalyn|jacinda|jacinta|jacinto|jacklyn|jackson|jacolyn|jacques|jadalyn|jakayla|jaliyah|jameson|jamison|jamisyn|" +
                                "janelle|janessa|janette|janiyah|janneke|january|japheth|jarlath|jarrell|jarrett|jasmine|jaunita|jauslyn|javonte|" +
                                "jayleen|jaylene|jaylynn|jazmine|jazmyne|jeanine|jeannie|jeffery|jeffrey|jemaine|jenelle|jenessa|jenifer|jensine|" +
                                "jeordie|jerahmy|jeramie|jeremey|jeremie|jericho|jerilyn|jerline|jermain|jerrell|jerrica|jerrold|jerusha|jessame|" +
                                "jessamy|jessica|jessika|jezabel|jezebel|jillene|jillian|jinivah|jisinia|joachim|joaquim|joaquin|jocasta|jocelyn|" +
                                "joelene|joellen|johanna|johnnie|johnson|jonatan|jordana|joretta|jørgen|joselyn|josepha|josette|joshuah|josylan|" +
                                "journee|journey|jovanni|jovanny|juanita|juliana|juliann|juliaun|julieta|julissa|junious|juniper|jupiter|justice|" +
                                "justice|justina|justine|justino)";
    namesDict.firstNames.j[8] = "(jacynthe|jaeleigh|jamarcus|jamarion|jannette|jaquelin|jeanette|jeannine|jebediah|jedediah|jedidiah|jefferey|jenalynn|" +
                                "jenibeth|jennifer|jennings|jeramiah|jeremiah|jermaine|jessalyn|jessamyn|jessenia|jessique|jocelyne|johannes|johnpaul|" +
                                "jonathan|jonathon|jørgina|joscelin|josefina|joycelyn|julianna|julianne|julienne|juliette)";
    namesDict.firstNames.j[9] = "(jackeline|jacquelin|jacquelyn|jacquline|jaqueline|jasperine|jeannette|jefferson|jeraldine|jessamine|jezabelle|" +
                                "johnathan|johnathon|josephina|josephine|julieanne)";
    namesDict.firstNames.j[0] = "(jackquelin|jacqueline|jaymii-lee|jeffersson|jewelianne)";
    namesDict.firstNames.k[3] = "(kai|kat|kay|kea|ken|kia|kim|kip|kit|kya)";
    namesDict.firstNames.k[4] = "(kaci|kacy|kade|kaia|kala|kale|kali|kami|kana|kane|kani|kara|kari|karl|kate|kati|katy|kaya|kaye|keda|keir|keli|kell|" +
                                "kent|keon|keri|kerr|khai|kian|kiel|kiki|kiku|kimm|kina|king|kino|kira|kiri|kirk|kirt|kiya|knox|knut|koba|kobe|koby|" +
                                "koda|kody|kofi|kojo|kole|kora|kori|kory|kris|kurt|kyan|kyla|kyle|kyna|kyra)";
    namesDict.firstNames.k[5] = "(kaari|kacey|kacie|kaden|kadin|kadir|kaela|kaija|kaila|kaisa|kaito|kaity|kaiya|kajsa|kalea|kaleb|kalen|kaleo|kaley|" +
                                "kalie|kalil|kalli|kally|kalyn|kamea|kamil|kandi|kandy|kanye|kaori|karan|karen|karie|karim|karin|karis|karla|karli|" +
                                "karly|karma|karol|karon|karri|karyn|kasey|kasie|kason|kathi|kathy|katia|katie|katya|kavon|kavya|kayla|kayli|kayse|" +
                                "kazuo|keane|keanu|keara|keary|kecia|keely|kegan|kehau|keiji|keila|keira|keith|kekoa|kelby|kelis|kelli|kelly|kelsi" +
                                "|kelsy|kelti|kenan|kenia|kenji|kenna|kenny|kenya|kenzo|keola|keoni|keren|kerri|kerry|kesha|ketan|keven|kevin|kevon|" +
                                "keyla|keyna|keyon|kezya|khera|khloe|kiana|kiara|kiera|kilby|kiley|kiran|kirby|kirsi|kisha|kitka|kitty|kizzy|klara|" +
                                "klaus|kogon|kolby|komal|koree|korey|kraig|krish|kubwa|kunal|kwame|kyara|kyden|kylah|kylan|kylea|kyleb|kylee|kyler|" +
                                "kylie|kylin|kylun|kyree|kyrie|kyron|kyros)";
    namesDict.firstNames.k[6] = "(kaatje|kabelo|kadeem|kaeden|kaedin|kaelyn|kagome|kahlil|kaiala|kaiden|kaidyn|kailee|kailey|kailyn|kalani|kalina|" +
                                "kallie|kalvin|kamari|kamaye|kamden|kamren|kamrie|kamron|kamryn|kandra|kareem|karina|karlee|karley|karlie|karlyn|" +
                                "karren|karrie|karson|karyme|kaspar|kassie|kateri|kathie|katina|katlin|katlyn|kattie|katyna|kaveri|kavita|kaycee|" +
                                "kayden|kaydra|kaylah|kaylee|kaylen|kayley|kaylie|kaylin|kaylyn|kazuki|keagan|keaton|keegan|keeler|keeley|keelin|" +
                                "keenan|keesha|keisha|keivar|kelcee|kelcie|kellan|kellen|kelley|kellie|kellyn|kelsea|kelsey|kelsie|kelton|kelvey|" +
                                "kelvin|kencil|kendal|kendon|kendra|kenede|kenelm|kenley|kenney|kenton|kenyon|kenzie|kepler|kerisa|kermit|kerrie|" +
                                "kerrin|kerwin|keshav|keshia|késse|keyona|keziah|khalid|khalif|khalil|khloee|khyree|kianna|kidada|kiefer|kieran|" +
                                "kierra|kieryn|kiirah|kijana|kilian|kimani|kimber|kimbra|kimika|kimora|kinley|kinnia|kinsey|kittie|knight|kohana|" +
                                "kolton|konner|konnor|korbin|kostas|kramer|krista|kristi|kristy|krysta|kurtis|kwanza|kymbre)";
    namesDict.firstNames.k[7] = "(kachina|kadence|kadynce|kaitlin|kaitlyn|kaleigh|kalilah|kaliyah|kamaria|kameron|kamilah|kandace|kandice|karalyn|" +
                                "karenna|karigan|karisma|karissa|karitas|karlene|karling|karmala|karolyn|karrisa|kassidy|katelin|katelyn|kathlyn|" +
                                "kathryn|katlynn|katriel|katrina|kaylynn|keishla|kellina|kenadee|kenadie|kendall|kenesaw|kennedi|kennedy|kennera|" +
                                "kenneth|kennith|kerensa|kerstin|keshaun|keshawn|kesslee|ketevan|keturah|khamari|kiffany|killian|kilmeny|kimball|" +
                                "kimisha|kineret|kingman|kinsley|kiriana|kirsten|kirstie|kirstin|kitarni|kjersti|kortney|kristal|kristan|kristel|" +
                                "kristen|kristie|kristin|kristyn|krystal|krysten|krystin|krystle|kyleena|kyleigh|kyllion|kyriaki|kyrsten)";
    namesDict.firstNames.k[8] = "(kadience|kaitlynn|kalliopi|karishma|kasandra|katarina|katarine|katelynn|katerina|katheryn|kathleen|kathrine|kathryne|" +
                                "kaydence|kayleigh|kayliece|keiralee|kelleigh|kellesha|kendrick|kennette|kennison|kenyatta|kerrigan|keyshawn|khadejah|" +
                                "khadijah|khe'anna|kheyaira|kiersten|kimberli|kimberly|kingsley|kingston|kourtney|kristian|kristina|kristine|kristjan|" +
                                "krystina|krystine|kushaiah)";
    namesDict.firstNames.k[9] = "(kaimbrynn|kassandra|kathaleen|katharina|katharine|katherine|kazimiera|kazimierz|kimberlee|kimberley|kimberlin|kristofer)";
    namesDict.firstNames.k[0] = "(kensington|khalfanee'|kherington|kristoffer|kristopher)";
    namesDict.firstNames.k[1] = "(keira-leigh|kimberleigh|konstantina)";
    namesDict.firstNames.k[3] = "(keeleigh-shae)";
    namesDict.firstNames.l[2] = "(lu)";
    namesDict.firstNames.l[3] = "(lea|lee|len|leo|les|lev|lew|lex|lia|liv|liz|lon|lou|loy|lt.|luc|lue|lux|luz|lyn)";
    namesDict.firstNames.l[4] = "(laci|lacy|lady|lael|lana|lane|lani|lara|lark|lars|leah|lear|leda|leia|leib|leif|lela|lena|leni|leon|lera|lesa|leta|" +
                                "levi|lexi|liam|liat|lida|liev|liko|lila|lily|lina|lior|lisa|lise|liza|lois|lola|loma|lona|loni|lora|lord|lori|love|" +
                                "loyd|luca|luce|lucy|luis|luka|luke|lula|lulu|lura|lyda|lyla|lyle|lynn|lynx|lyra)";
    namesDict.firstNames.l[5] = "(laban|lacey|lacie|laila|laine|laird|lakin|lakyn|lalit|lamar|lamel|lamia|lance|lando|laney|lanie|lanny|laron|larry|" +
                                "larue|lasse|latif|laura|lauri|laver|lavin|lavon|laxmi|layla|layle|layne|lazar|leann|leena|leesa|leigh|leila|leisa|" +
                                "leith|lelah|lelia|lemma|lemon|lempi|lenka|lenna|lenny|leola|leoma|leona|leone|leora|leota|leroy|lesia|lesli|lesly|" +
                                "letha|levar|levon|lewis|lexie|lexus|lezli|liana|libby|lidia|liesl|lilac|lilah|lilia|lilla|lilly|linda|lindy|linus|" +
                                "liora|lisha|lissa|litzy|livia|lloyd|logan|loïc|lonie|lonna|lonny|lonzo|loran|loren|lorie|lorin|lorna|lorne|lorri|" +
                                "lotta|lotte|lotus|louie|louis|lovie|lowri|loyal|loyce|luana|luann|lucas|lucia|lucie|lucio|lucky|ludie|luigi|luisa|" +
                                "lukas|luken|lyale|lydia|lyman|lynda|lyndi|lynee|lynne|lyric)";
    namesDict.firstNames.l[6] = "(laddie|ladeca|laelia|lærke|lainey|laisha|lalita|lamont|landen|landon|landry|landyn|lanisa|lannie|laoise|larisa|" +
                                "larkin|larsen|larson|laszlo|lathyn|latifa|latika|latoya|lauran|laurel|lauren|laurie|lauryn|lavada|lavera|lavern|" +
                                "lavina|lawson|layton|lazaro|leamon|leanna|leanne|leatha|lebron|leeann|leeroy|leland|lemuel|lenard|lennie|lennon|" +
                                "lennox|lenora|lenore|leonel|leonid|leonor|leotis|leslee|lesley|leslie|lessie|lester|lettie|lexsly|liadan|lianna|" +
                                "libbie|lienna|liesel|lilian|lilias|lilith|lilium|lillie|lilyan|linden|lindie|linnae|linnea|linnet|linnie|linsey|" +
                                "lionel|lizeth|lizzie|lofton|lolita|lonán|londen|london|londyn|lonnie|lorcan|lorena|lorene|lorenz|loreto|lorine|" +
                                "lorrie|lottie|louann|loudon|louisa|louise|lovisa|lowell|luanna|luanne|lucero|lucian|lucien|lucila|lucile|lucius|" +
                                "ludwig|luella|luetta|luther|lynden|lyndon|lynlea|lynnae|lynsey)";
    namesDict.firstNames.l[7] = "(lachlan|ladonna|laertes|lakenya|lakesha|lakisha|lakshmi|lambert|lambros|lanette|langdon|lanigan|laquita|laraine|" +
                                "laramie|larissa|lashawn|latanya|latasha|latisha|latonia|latonya|latosha|latrell|latrice|laurana|laureen|laurent|" +
                                "laurine|laverna|laverne|lavinia|lavonne|lawanda|lazarus|leander|leandra|leandro|legolas|leilani|leonard|leonato|" +
                                "léonie|leonora|leonore|leopold|leticia|letitia|lettice|leyanna|liadain|liberty|liliana|liljana|lillian|lilyana|" +
                                "lincoln|lindsay|lindsey|linette|linwood|lisbeth|lisette|liviana|lizbeth|lizette|lleyton|loraine|loralai|loralie|" +
                                "lorelai|lorelei|lorenza|lorenzo|loretta|loriann|louella|lourdes|lovetta|luciana|luciano|lucilla|lucille|lucinda|" +
                                "lucious|lucrece|ludmila|ludovic|lugenia|lurline|luvenia|luzetta|lyndsay|lyndsey|lynette|lynwood)";
    namesDict.firstNames.l[8] = "(ladarius|lakeisha|lakeshia|lancelot|langston|lashanda|lashonda|latricia|lauralee|laurence|lauretta|laurette|" +
                                "lavender|lawrence|leatrice|lefteris|leighton|leocadia|leonardo|leonidas|leontine|leopoldo|lilianna|lilibeth|" +
                                "lilliana|lisandra|lisandro|lissette|lizabeth|lorccán|lorraine|louvenia|lucienne|lucretia|ludivine|ludmilla|" +
                                "lynnelle|lynnette|lysander)";
    namesDict.firstNames.l[9] = "(lafayette|lawerence|leviticus|lexington|lillianna|liselotte|llewellyn)";
    namesDict.firstNames.l[10] = "(laurentius|lieselotte|lieutenant)";
    namesDict.firstNames.m[2] = "(m.)";
    namesDict.firstNames.m[3] = "(mac|mae|max|meg|mel|mia|miu|moa|moe|mr.|ms.|mya)";
    namesDict.firstNames.m[4] = "(mace|maci|mack|macy|mada|mads|maia|maj.|maja|mako|mali|mara|marc|mari|mark|mars|mary|matt|maud|maya|maye|meda|" +
                                "mena|merl|meta|miah|mika|mike|mila|milo|mimi|mina|ming|mira|miro|miss|miya|mme.|mona|moon|mose|moss|mrs.|murl|myah|" +
                                "myla|myra|myrl)";
    namesDict.firstNames.m[5] = "(mabel|mable|macey|macie|macon|madge|madie|maeby|maeva|maeve|magic|mahir|mahri|maida|maile|maira|maire|mairi|maisy|" +
                                "major|major|makal|makis|malia|malik|malin|malka|malte|mamie|mandi|mandy|manja|manly|manoj|manon|manos|mansi|manus|" +
                                "manzi|marat|marci|marco|marcy|marek|maren|marge|margo|margy|maria|marie|marin|mario|maris|marit|marla|marlo|marta|" +
                                "marty|marva|maryn|masha|masis|mason|matea|mateo|maude|maura|mauro|maury|maven|mavis|maxie|maxim|mayme|mayra|mazie|" +
                                "mccoy|mckay|meade|mearl|medbh|media|meeta|megan|mehri|meika|mekhi|melba|melia|melva|mercy|merit|merle|merry|meryl|" +
                                "meyer|micah|mieke|mihir|mikah|mikel|milan|miles|miley|milla|milly|milos|mindi|mindl|mindy|minea|minka|minna|mirna|" +
                                "mirta|mirth|misha|missy|misti|misty|mitch|mitzi|mlle.|moira|molly|monte|monty|moody|morag|moses|moshe|msgr.|mulan|" +
                                "mungo|murry|myava|mylee|myles|mylie|myrle|myrna|myron)";
    namesDict.firstNames.m[6] = "(mackie|macsen|madame|madden|maddie|maddox|maddyn|madsen|maegan|maelle|magali|maggie|magnus|mahala|mahesh|mahlon|" +
                                "maigen|maille|maisey|maisha|maisie|maizie|makala|makani|makena|malaki|malcom|maleah|malene|malila|mallie|mammie|" +
                                "manish|manley|mannix|manuel|marcel|marcia|marcie|marcos|marcus|marely|margie|margit|margot|mariah|mariam|marian|" +
                                "mariel|marika|marina|marine|marion|marios|marisa|marita|marius|markel|markos|markus|marlee|marlen|marley|marlin|" +
                                "marlon|marlyn|marlys|marnie|marsha|martha|martin|marvel|marvin|maryam|maryjo|masika|maslyn|master|mathew|mathis|" +
                                "matias|mattea|matteo|mattia|mattie|mattox|maudie|maxima|maximo|maxine|maxton|maymie|maysen|mayzee|meadow|meagan|" +
                                "meegyn|meggin|meghan|meghyn|melany|meliah|melina|melisa|mellie|mellyn|melody|melora|melton|melvin|melvyn|mercer|" +
                                "merlin|merlyn|merryn|mersia|mertie|merton|mervin|mervyn|merwin|meziah|mhairi|michal|michel|miciah|mickey|mickie|" +
                                "midori|miesha|mignon|miguel|mikala|mikkel|miklos|milcah|milena|millan|miller|millie|milton|minnie|mintie|mirela|" +
                                "mireya|miriam|mirren|misael|misaki|mischa|mittie|moises|mollie|monica|monika|monroe|morgan|moriah|moritz|morris|" +
                                "morton|morven|moshon|mossie|mozell|muriel|murphy|murray|myriam|myrthe|myrtie|myrtis|myrtle)";
    namesDict.firstNames.m[7] = "(m'kaela|mabelle|macaria|maclean|macleod|macrina|madalyn|madelca|madelyn|madhuri|madigan|madilyn|madisen|madison|" +
                                "madisyn|madonna|madyson|maëlys|mafalda|maguire|mahalia|mahmoud|mahoney|mairead|majella|makaela|makaila|makayla|" +
                                "makenna|makinzi|malachi|malachy|malaika|malakai|malcolm|malinda|malissa|maliyah|mallika|mallory|maloree|malorie|" +
                                "malvina|manfred|manisha|manuela|maranda|marcela|marcelo|marcial|margaux|margery|margret|mariana|mariann|mariano|" +
                                "maribel|mariela|marieta|marifel|marilee|marilla|marilou|marilyn|mariska|marisol|marissa|maritza|marjory|markell|" +
                                "markian|marland|marlena|marlene|marlowe|marolyn|marques|marquez|marquis|marsden|marshal|martina|marusia|maryann|" +
                                "marylin|marylou|marylyn|mathias|mathieu|matilda|matilde|matilyn|matthew|mattson|maudeen|maureen|maurice|maurine|" +
                                "maximus|maxwell|maybell|maynard|mckayla|mckenna|mckenzy|meaghan|mederic|meghann|melania|melanie|melinda|melissa|" +
                                "mellisa|melodie|melonie|melvina|memphis|meranda|mercury|merilyn|merlene|merrick|merrill|merritt|messiah|micaela|" +
                                "micaiah|michael|micheal|michela|michele|michell|mikaela|mikaila|mikayla|mikenzi|mikhail|milburn|mildred|milford|" +
                                "millard|minerva|mirabel|miracle|miranda|mirella|mitchel|modesta|modesto|mohamed|monique|montana|morgann|mozella|" +
                                "mozelle|mustafa|myfanwy|myranda|myrtice)";
    namesDict.firstNames.m[8] = "(macaulay|machelle|mackland|madalena|madalina|madaline|madalynn|maddison|madeline|madelynn|magdalen|magnolia|" +
                                "mahogany|makenzie|manervia|marabeth|marcella|marcelle|marcello|margalit|margaret|mariamne|marianna|marianne|" +
                                "maribeth|maricela|maricris|mariella|marietta|mariette|marigold|marilena|marilene|marilynn|mariposa|marisela|" +
                                "marjorie|markisha|marquise|marquita|marshall|maryanne|marybeth|maryjane|mathilda|mathilde|matthias|matthijs|" +
                                "mauricio|maverick|maxfield|maximino|maybelle|mcarthur|mckelvey|mckenzie|mckinley|mckinney|mechelle|melchior|" +
                                "meliauna|mellissa|melodean|melusine|melville|mercedes|meredith|meridith|merrigan|miabella|michaela|michaele|" +
                                "michalis|michelle|migdalia|mikaylee|mikhaila|milagros|milligan|minuette|mireille|missouri|mitchell|mo'nesha|" +
                                "mohammad|mohammed|mohinder|monsieur|montague|mordecai|morpheus|morrigan|morrison|mortimer|morwenna|muhammad)";
    namesDict.firstNames.m[9] = "(maaskelah|mackenzie|maddalena|madeleine|magdalena|magdalene|maraminah|marcelina|marceline|marcelino|marcellus|" +
                                "margarete|margarett|margarita|margarito|mariclare|marseille|mary-anne|marybelle|maryellen|mehitabel|melbourne|" +
                                "melisande|michalina|michelina|millicent|minaluccy|mindelynn|mirabella|mirabelle|mnemosyne|monserrat|monsignor|" +
                                "mordechai)";
    namesDict.firstNames.m[10] = "(margaretta|margarette|margherita|marguerite|maristella|marjolaine|maximilian|melyssande|mishavonna|monserrate|" +
                                "montgomery|maximiliano|maximillian|mademoiselle|michelangelo)";
    namesDict.firstNames.n[3] = "(nan|nat|ned|neo|nia|noa|noe|nya)";
    namesDict.firstNames.n[4] = "(nash|nate|nava|navi|neal|neil|nell|nels|nemi|nemo|neta|neva|neve|nick|nico|nida|nika|niki|niko|nila|nils|nina|" +
                                "nita|noah|noam|noel|nola|nona|nora|nova|nuno|nver|nyah|nyla)";
    namesDict.firstNames.n[5] = "(nadia|nadya|nahla|naima|naite|najee|nakia|nakul|namie|nanci|nancy|nanna|naoko|naoma|naomi|nareh|nasir|nedra|neema|" +
                                "nelda|nella|nelle|nelly|neoma|nephi|nevin|niall|niamh|nicki|nicky|niels|nieva|nieve|nigel|nihad|nikki|nikos|nilda|" +
                                "niles|nilsa|nimue|nissa|nixie|noble|noemi|nolan|norah|norma|nuala|nuria|nydia|nyree|nyssa)";
    namesDict.firstNames.n[6] = "(nacole|nadine|nahima|nalani|nancie|nannie|nastia|nataly|natasa|nathan|nathen|natoya|naveen|nayeli|nayely|nekeia|" +
                                "nelida|nellie|nelson|nessim|nestor|nettie|nevaeh|neveah|newell|newman|newton|nichol|nicola|nicole|nikhil|nikita|" +
                                "niklas|nikohl|nikole|nimrod|nirali|nissim|noelia|noelle|noreen|norene|norine|norman|norris|norton|norval|nunzio|nyasia)";
    namesDict.firstNames.n[7] = "(nadalyn|nallely|nanette|narciso|natalee|natalia|natalie|natalya|natasha|nathaly|natosha|nautica|neftali|neilson|" +
                                "nephele|nereida|nerissa|neville|nichole|nicolas|nicolle|nikolai|nikolas|noelani|noémie|nolwenn|norbert|normand|" +
                                "norwood|novella)";
    namesDict.firstNames.n[8] = "(nadezhda|nannette|naphtali|napoleon|natalina|nathalee|nathalia|nathalie|nehemiah|nemanuel|nicholas|nicklaus|" +
                                "nickolas|nicolene|nicoline|nikolaos|nikoleta|norberto|normandy)";
    namesDict.firstNames.n[9] = "(nadeleine|nataleigh|nathanael|nathanial|nathaniel|natividad|necessity|nicholaus|nicholson|nicodemus|nicoletta|nicolette)";
    namesDict.firstNames.n[10] = "(nicomachus)";
    namesDict.firstNames.n[11] = "(nightingale)";
    namesDict.firstNames.o[2] = "(oz)";
    namesDict.firstNames.o[3] = "(oda|ola|ole|oma|ona|ora|ova)";
    namesDict.firstNames.o[4] = "(obed|obie|ocie|odie|odin|odis|okey|olaf|olan|oleg|olen|olga|olie|olin|omar|omer|omie|onie|onyx|oona|opal|oral|" +
                                "oran|oren|orie|orin|orla|orlo|orly|osia|otha|otho|otis|otto|owen)";
    namesDict.firstNames.o[5] = "(odell|odile|odina|odion|ogden|oisin|olena|olene|oleta|olive|ollie|olwen|omari|oneal|onnie|oprah|orion|orpha|orrin|" +
                                "orson|orval|orvil|osaka|osama|oscar|oskar|ossie|otten|ottie|ottis|ouida)";
    namesDict.firstNames.o[6] = "(oakley|oberon|oceana|ochuko|octave|odalys|odelia|odessa|odetta|odette|odilia|ofelia|oksana|oliver|olivia|omayra|" +
                                "onycha|oralia|orange|orchid|oriana|oriane|oriono|orland|orlean|oswald|otilia|ozella|ozette)";
    namesDict.firstNames.o[7] = "(ophélie|o'brien|obadiah|octavia|octavio|odyssey|olimpia|olivié|olivier|olympia|omarion|ontario|ophelia|orabela|" +
                                "orlaith|orlando|orpheus|orville|osbaldo|osborne|osvaldo|oswaldo|othello|ottilie)";
    namesDict.firstNames.o[8] = "(o'rourke|octavian|octavius|oleander|oliviana)";
    namesDict.firstNames.o[10] = "(ozymandias)";
    namesDict.firstNames.o[4] = "(oghenerioborue)";
    namesDict.firstNames.p[3] = "(pam|pat|pax|paz|per|pia|pio|pip)";
    namesDict.firstNames.p[4] = "(paul|penn|peri|peta|pete|phil|piet|pink|plum|poet|polk|posy|pria|pura|purl)";
    namesDict.firstNames.p[5] = "(pablo|padma|paige|palma|pamla|panos|pansy|paola|paolo|paris|parul|patsy|patta|patti|patty|paula|paulo|pavel|payne|" +
                                "peace|pearl|pedro|peggy|pella|pemba|penda|penni|penny|peony|percy|perez|perla|perri|perry|peter|petra|philo|piers|" +
                                "pieta|pilar|pilot|piper|pippa|polly|poppy|pres.|price|primo|priya|prof.|pryor)";
    namesDict.firstNames.p[6] = "(packer|padarn|paetyn|paikea|palmer|paloma|pamala|pamela|paresh|parisa|parker|parnel|pascal|patten|pattie|pavely|" +
                                "pavlos|paxton|payton|pearle|peggie|pelham|pennie|perrin|pervis|petros|petrus|petula|peyton|philip|philon|phoebe|" +
                                "phylis|pierce|pierre|pieter|pietro|pinkie|pomona|porsha|porter|portia|potter|pranav|primus|prince|prisca|profit|" +
                                "prudie|psyche)";
    namesDict.firstNames.p[7] = "(padraig|paisley|palmira|pamella|pandora|pangfua|paradis|parrish|parvati|pascale|pascual|patrice|patrick|paulina|" +
                                "pauline|pearlie|perdita|pernell|petrina|phaedra|phaeton|phillip|phillis|philoma|phinean|phineas|phoenix|phyllis|" +
                                "pierson|pinchas|placido|pradeep|presely|presley|preston|primula|promise|prosper|ptolemy)";
    namesDict.firstNames.p[8] = "(parthena|pasquale|patience|patricia|patricio|patrizia|pauletta|paulette|pearline|peerless|penelope|percival|" +
                                "pericles|permelia|pershing|petronel|pheasant|pheriche|philippa|philippe|phillipe|phyllida|pomeline|porfirio|" +
                                "precious|prescott|primrose|princess|princess|priscila|prospero|prudence|prunella)";
    namesDict.firstNames.p[9] = "(panagiota|peregrine|philomena|phylicity|president|primitivo|priscilla|professor)";
    namesDict.firstNames.p[10] = "(parthenope|persephone|petronilla|proserpina|providenci)";
    namesDict.firstNames.q[5] = "(quaid|queen|quinn)";
    namesDict.firstNames.q[6] = "(quiana|quincy)";
    namesDict.firstNames.q[7] = "(queenie|quentin|quinlan|quinten|quintin|quinton|quintus)";
    namesDict.firstNames.r[3] = "(rae|raj|ram|ray|raz|ren|rex|rey|rie|rio|rob|rod|ron|roy|rye)";
    namesDict.firstNames.r[4] = "(race|rafe|rahm|rain|rand|rane|rani|raul|ravi|raya|reba|reed|reid|rena|rene|reno|rep.|reta|rev.|reva|reza|rhea|" +
                                "rhen|rhys|ría|rich|rick|rico|riga|rika|riko|rima|risa|rita|riya|roan|roar|robb|robi|roby|rock|roel|rojo|rolf|roly|" +
                                "roma|rome|romy|rona|roni|rory|rosa|rose|ross|rubi|ruby|rudy|ruel|ruff|runa|rune|rush|russ|ruth|ryan|ryla|ryne)";
    namesDict.firstNames.r[5] = "(rabbi|rafer|raffi|rahul|raina|raine|raisa|raita|rajat|rajiv|ralph|ramey|ramon|ramya|rance|randi|randy|rania|raoul|" +
                                "rasha|raven|ravyn|rayna|rayne|razia|reece|reese|regan|regis|reina|reino|rekha|remus|rémy|renae|renea|renee|resha|" +
                                "retha|retta|reuel|revs.|reyes|reyna|rheta|rhett|rhian|rhoda|ricki|ricky|rider|ridge|rieko|rigby|rigel|rikki|riley|" +
                                "rilla|ringo|riona|rishi|risto|river|rivka|roald|roark|robby|robin|robyn|rocco|rocky|rogan|roger|rogue|rohan|roick|" +
                                "rolla|rollo|roman|romeo|ronan|ronda|ronen|ronia|ronin|ronit|ronja|ronna|ronny|roque|rosia|rosie|roula|rowan|rowdy|" +
                                "rowen|roxie|royal|royce|ruben|rubie|rubin|rubye|rufus|rusty|ruthe|ryann|ryder|ryker|rylan|rylee|ryley|rylie|rylin)";
    namesDict.firstNames.r[6] = "(rachel|raeann|raegan|rafael|raffia|ragnar|raheem|rahima|raiden|rainen|rainer|rainey|rajesh|rakesh|ramesh|ramiro|" +
                                "ramona|ramsay|ramsey|randal|randel|randle|ranger|raniel|ranjit|ransom|raquel|rashad|rashid|rasmus|raymon|rayner|" +
                                "raynne|raziel|reagan|reagen|reanna|reason|rebeca|reggie|regina|rehema|reidar|reilly|renata|renate|renato|renita|" +
                                "renner|reshma|ressie|reuben|rey'el|rheyna|rhodes|rhodri|rhonda|rianna|richie|rickey|rickie|ridley|ripley|roarke|" +
                                "robbie|robbin|robert|rochel|rocío|rodger|rodman|rodney|roenne|rogers|rohini|roisin|roland|rollie|rollin|romain|" +
                                "romare|romina|romola|romona|ronald|ronnie|rosana|rosann|roscoe|rosina|rosita|roslyn|rossie|rourke|rowena|roxana|" +
                                "roxane|roxann|rudolf|rueben|ruffin|rupert|rushil|russel|rutger|ruthie|ryanne|rykken|ryland)";
    namesDict.firstNames.r[7] = "(rachael|racheal|racquel|radames|radhika|raekwon|rafaela|rahsaan|rainbow|raleigh|randall|randell|rannoch|raphael|" +
                                "rashawn|rasheed|rashida|rayburn|rayelle|rayford|raymond|raynard|rebecca|rebekah|redmond|refugio|reginal|rexford|" +
                                "reynold|rhianna|ricardo|richard|rihanna|riordan|ritchie|riviera|roberta|roberto|rodolfo|rodrick|rodrigo|rogelio|" +
                                "rolanda|rolando|rolland|romaine|romilda|romilly|romulus|ronaldo|rosabel|rosaire|rosalba|rosalee|rosalia|rosalie|" +
                                "rosalva|rosalyn|rosanna|rosanne|rosaria|rosario|rosaura|roseann|rosella|roselyn|rosendo|rosetta|roswell|rowland|" +
                                "roxanna|roxanne|rozella|ruairí|rudiger|rudolph|rudyard|russell|ruthann|ryleigh)";
    namesDict.firstNames.r[8] = "(rachelle|ramonita|randolph|raphaela|rayleigh|raymundo|rayshawn|reginald|reinaldo|reinhold|renesmee|reverend|" +
                                "reynaldo|rhiannon|riccardo|richelle|richmond|rickelle|robinson|rochelle|rockwell|roderick|rosaleen|rosalina|" +
                                "rosalind|rosaline|rosamond|rosamund|roseanna|roseanne|roselina|rosemary|rosevelt)";
    namesDict.firstNames.r[9] = "(raffaella|remington|reverends|rhieannah|rigoberto|roosevelt|rosabella|rosalinda|rosemarie)";
    namesDict.firstNames.r[10] = "(rutherford)";
    namesDict.firstNames.r[11] = "(rockefeller)";
    namesDict.firstNames.r[14] = "(representative)";
    namesDict.firstNames.s[3] = "(st.|sal|sam|sid|sim|sir|sky|sol|sr.|sr.|sue|sun)";
    namesDict.firstNames.s[4] = "(sade|saga|sage|sama|sani|sara|saul|scot|sean|sela|sen.|sepp|seth|sgt.|shad|shae|shai|shay|shea|shia|shon|sian|" +
                                "sire|siri|skip|skye|sra.|stan|star|suki|suri|suvi|suzy|svea|sven|swan|syed)";
    namesDict.firstNames.s[5] = "(saint|saari|sabah|saber|sabry|sacha|sadie|sadye|sagar|saige|salim|sally|salma|samir|sammy|sampo|sanaa|sandi|" +
                                "sandy|sania|sanna|sanne|sanni|sansa|santa|santo|sarah|sarai|sasha|sayer|sayli|scott|scout|sedna|selah|selby|selim|" +
                                "selma|semaj|senan|senna|senor|seren|seven|sevin|shadi|shana|shane|shani|shara|shari|shaun|shawn|shaye|sheri|shira|" +
                                "shola|shona|shura|shyla|sibyl|siena|siera|signe|silas|síle|siler|silje|silka|simba|simon|sindi|sipho|siren|sixto|" +
                                "skyla|slade|sloan|smith|sofia|sofie|solon|sonia|sonja|sonny|sonya|soren|sorin|spike|srta.|staci|stacy|starr|steno|" +
                                "steve|stine|stone|storm|story|sudie|sukey|sukie|sunil|sunny|surya|susan|susie|suuvi|suzan|sybil|syble|sydni|sylas|sylve)";
    namesDict.firstNames.s[6] = "(sabela|sabelo|sabina|sabine|sadaat|saddam|sadhbh|sadler|safiya|sahara|sailor|sakari|sakura|salima|salina|sallie|" +
                                "salome|samara|samira|sammie|samson|samuel|sander|sandra|sandro|saniya|sanjay|santos|sarahi|saraya|sariah|sarina|" +
                                "sascha|saskia|saskie|savana|savina|savion|savvas|sawyer|scotty|seager|seamus|seaton|sedona|selena|selene|selina|" +
                                "selmer|seneca|senora|seraph|serena|sergei|sergio|severo|shadow|shaina|shamar|shanda|shania|shanna|shanon|shanta|" +
                                "shante|shanti|sharee|sharen|sharif|sharla|sharon|sharyn|shasta|shauna|shawna|shayla|shayna|shayne|sheena|sheikh|" +
                                "sheila|shelba|shelbi|shelby|shelia|shelli|shelly|shelva|shemar|sheree|sherie|sheron|sherri|sherry|sheryl|sheyla|" +
                                "shiela|shifra|shiloh|shimon|shivam|shmuel|shonda|shonna|shreya|shyann|sianna|sidney|sidony|sienna|sierra|sigrid|" +
                                "sigurd|sillan|silvan|silver|silvia|silvio|simcha|simeon|simona|simone|sinbad|sindri|sinead|sirius|sissel|sister|" +
                                "sister|sivert|skilee|skylan|skylar|skyler|slater|sloane|soeren|solana|soleil|sondra|sonnet|sonoma|sonora|sookie|" +
                                "sophia|sophie|soraya|sorcha|sorrel|spence|spiros|spring|squire|stacey|stacia|stacie|starla|stasia|stasya|steele|" +
                                "stefan|stella|stevan|steven|stevie|stoney|stormy|struan|stuart|summer|sumner|sunday|susana|susann|sutton|suzann|" +
                                "sydnee|sydney|sydnie|sylvan|sylvia|sylvie)";
    namesDict.firstNames.s[7] = "(sabrina|sadhana|saffron|samaria|sandeep|sanford|saniyah|sanjeev|santana|santina|santino|saoirse|saphira|sargent|" +
                                "satchel|sathish|saundra|savanah|savanna|scarlet|scottie|seattle|sedrick|senator|sephora|sereana|severin|severus|" +
                                "seymour|sha'uri|shaelyn|shaheen|shakila|shakira|shameka|shamika|shanice|shanika|shanita|shaniya|shannan|shannon|" +
                                "shantel|sharona|sharron|shaylee|shaylie|shelbie|sheldon|shelina|shelley|shellie|shelton|shepard|shepley|sherita|" +
                                "sherlyn|sherman|sherrie|sherron|sherryl|sherwin|shianne|shirlee|shirley|shivani|shyanne|sibylla|sidonia|sidonie|" +
                                "sigmund|simpson|sincere|siobhan|skipper|socorro|solange|soledad|solomon|solveig|sorrell|sotiria|sparrow|spencer|" +
                                "spenser|stanley|stanton|stavros|stefani|stefano|steffan|stelios|stellan|stephan|stephen|stephon|stetson|stewart|" +
                                "strider|suellen|sunniva|sunrise|surelis|susanna|susanne|sushila|suzanna|suzanne|suzette|sybylla|sylvain)";
    namesDict.firstNames.s[8] = "(salvador|samantha|sandrine|sangeeta|sanjukta|santiago|sapphira|sapphire|savannah|scarlett|schuyler|scorpius|" +
                                "senorita|septimus|serafina|seraphia|serenity|sergeant|severena|severina|shaienne|shalimar|shalonda|shanelle|" +
                                "shaniqua|shaniyah|shantell|sharalyn|sharlene|sharonda|shawanda|shenequa|sheppard|sheridan|sherilyn|sherlock|" +
                                "sherrill|sherwood|shim-hee|shirlene|shoshana|siddalee|silvanus|sinclair|slobodan|socrates|spearman|spellman|" +
                                "spurrier|squandro|stafford|stanford|starling|stefania|stefanie|stefanos|stephani|stephany|sterling|stockman|" +
                                "stratton|styliani|sullivan|sunshine|surinder|susannah|suzannah|svetlana)";
    namesDict.firstNames.s[9] = "(sabastian|salvatore|sanderson|seathrún|sebastian|september|serallies|seraphina|seraphine|shahrazad|shannessy|" +
                                "shaquille|shoshanna|silatuyok|sojourner|sophronia|stanislas|stanislav|stanislaw|stephania|stephanie|stephenie|" +
                                "sylvester)";
    namesDict.firstNames.s[10] = "(sébastien|sévérine|shenandoah|stanislaus|stanislava)";
    namesDict.firstNames.s[11] = "(salustianna|scholastica)";
    namesDict.firstNames.t[2] = "(ty)";
    namesDict.firstNames.t[3] = "(tad|tag|tai|taj|tal|tam|tea|ted|teo|tex|tia|tim|tip|tod|tom|toy|tre|tru|tui)";
    namesDict.firstNames.t[4] = "(taft|tahj|tait|tali|tami|tana|tara|tate|tave|taya|tayo|teal|tena|tera|teri|tess|teyo|thad|thea|theo|thor|tifa|till|" +
                                "timo|tina|tino|tiny|tisa|tito|toby|todd|toni|tony|tora|tori|tory|tova|tove|toya|trae|trey|trig|troy|tuva|tyce|tyme|" +
                                "tyne|tyra)";
    namesDict.firstNames.t[5] = "(taber|tadhg|tahki|taide|taimi|taina|takis|talan|talia|talon|talya|tamar|tamia|tamie|tamir|tammi|tammy|tamra|tamya|" +
                                "tandi|tania|tanis|tanja|tanya|tarah|taran|taras|tarek|tarez|tariq|tarun|taryn|tasha|tatum|tavis|tavon|tavor|tawny|" +
                                "tayla|tayne|tecla|teddy|teena|tegan|telly|terra|terri|terry|tesla|tessa|tevel|tevin|thabo|thain|thais|thane|theda|" +
                                "thijs|thoma|thora|thyra|tiago|tiana|tiara|tibor|tiera|tiger|tiggy|tilda|tillo|tilly|timmy|timon|tinka|tisha|titus|" +
                                "tobey|tobin|tomas|tommy|toney|tonia|tonja|tonna|tonya|topaz|torey|torin|torry|tosha|toshi|tovah|trace|traci|track|" +
                                "tracy|trena|trent|tresa|treva|trina|troah|trudy|truth|tsega|tudor|twila|twyla|tycho|tyler|tylor|tymon|tyree|tyrel|" +
                                "tyriq|tyron|tyson|tytus)";
    namesDict.firstNames.t[6] = "(tahira|taisha|takoda|talbot|talise|talyse|tamala|tamana|tamara|tameka|tamela|tamera|tamika|tamiko|tammie|tammis|" +
                                "tamryn|tamsin|tanika|tanith|taniya|tannen|tanner|tannis|taraji|tarian|tarkin|tarren|tarsha|tarzan|tasker|tavean|" +
                                "tavian|tavion|tavish|tawana|tawnee|tawnya|tayler|taylor|teagan|teague|tearny|teghan|temily|tempie|temple|tennie|" +
                                "tenzin|teresa|terese|tereza|terrie|terttu|tesoro|tessie|thalia|thames|thandi|thanos|thayer|thekla|thelma|theola|" +
                                "theora|theron|theryn|thomas|thraci|tianna|tierra|tierza|tilden|tillie|tilney|timara|timbre|timmie|tirion|tirzah|" +
                                "tishia|tizian|tobias|tollak|tomasa|tomeka|tomika|tomlin|tommie|tomoko|torben|torrey|torrii|townes|tracey|tracie|" +
                                "traian|trajan|traver|travis|travon|tressa|trever|trevik|trevin|trevon|trevor|tricia|trilby|triona|trisha|trista|" +
                                "triton|trixie|trudie|truett|truman|tucker|tullia|tullis|turner|tybalt|tychon|tyesha|tyquan|tyreek|tyrell|tyrese|tyrone)";
    namesDict.firstNames.t[7] = "(tabatha|tabitha|tacitus|taffeta|taggert|takashi|talitha|taliyah|tamatha|tanaraq|tanesha|tangela|tanisha|taniyah|" +
                                "tarquin|tatanka|tatiana|tatiara|tatyana|taurean|tavares|tawanda|tawanna|teaghan|tempest|tenisha|teodoro|terence|" +
                                "teressa|terrell|terrill|tetyana|texanna|teyarna|theodyn|theresa|therese|theseus|thibaut|thierry|thomsen|thulani|" +
                                "thurman|tiernan|tierney|tiffani|tiffany|tillman|timfany|timoteo|timothy|tinashe|tinsley|titania|tiziana|tokunbo|" +
                                "tomache|tommaso|torquil|torsten|toshiko|toumani|townley|trayton|trenean|trenten|trenton|tressie|trevion|treyton|" +
                                "treyvon|trinity|tristan|tristen|tristin|triston|trystan|tuesday|tullius|tyreena|tyreese|tyrique|tyshawn)";
    namesDict.firstNames.t[8] = "(taitlynn|tallulah|talmadge|tatianna|tatyanna|tayshaun|tecumseh|tennille|tennyson|teresita|terrance|terrence|" +
                                "thaddeus|thanasis|thanatos|thandeka|thandiwe|thatcher|theadore|thembeka|theodora|theodore|theresia|thomasin|" +
                                "thomasyn|thornton|thurston|tiberius|tiffanie|timmerle|timmothy|timothea|torrance|treasure|tremaine|tremayne|" +
                                "trinidad|tristian|tristram)";
    namesDict.firstNames.t[9] = "(tayliauna|thelonius|theodoric|theodosia|theophile|thomasina|thomasine|tigerlily|ty-nassir|tzipporah)";
    namesDict.firstNames.t[10] = "(temperance|theodosius|theophanes|theophilus)";
    namesDict.firstNames.u[3] = "(udo|ugo|ulf|uma|una|urd|uri|uzi)";
    namesDict.firstNames.u[4] = "(ulla|urho|uzzi)";
    namesDict.firstNames.u[5] = "(ultan|unity|upton|urban|uriah|urias|uriel|usher)";
    namesDict.firstNames.u[6] = "(uberto|ulises|ulrich|ulrika|undine|unique|ursula|utahna|uzziah)";
    namesDict.firstNames.u[7] = "(ulysses|umberto)";
    namesDict.firstNames.v[3] = "(val|van|von)";
    namesDict.firstNames.v[4] = "(vada|vale|veda|vega|vena|vera|verl|vern|vida|vina|vita|vito|viva)";
    namesDict.firstNames.v[5] = "(vadim|valia|vance|varun|velda|vella|velma|velva|venus|verda|verla|verna|verne|vesta|vicki|vicky|vidal|vidar|vidya|" +
                                "viggo|vijay|vikki|vilde|ville|vilma|vince|vinia|viola|vitus|vonda)";
    namesDict.firstNames.v[6] = "(vaclav|valery|vallie|vanesa|vanity|vashti|vaughn|velvet|venice|venita|verdie|verena|vergie|vergil|verica|verity|" +
                                "verlie|verlin|verner|vernie|vernon|verona|versie|veruca|vester|vickey|vickie|victor|vienna|vigdis|vikram|viktor|" +
                                "vinnie|vinson|violet|virgie|virgil|viveca|vivian|vivien|volker|vonnie)";
    namesDict.firstNames.v[7] = "(valancy|valarie|valente|valeria|valerie|valerio|valorie|vandana|vanessa|vasilis|vaughan|venessa|venetia|vernell|" +
                                "vernice|vicenta|vicente|vincent|violeta|viviana|vorgell)";
    namesDict.firstNames.v[8] = "(va'lexus|valarece|valdemar|valencia|valentin|vangelis|vassilis|veronica|veronika|victoria|vincenza|vincenzo|" +
                                "violetta|violette|virgilio|virginia|virginie|vittoria|vittorio|vivienne|vladimir)";
    namesDict.firstNames.v[9] = "(valentina|valentine|valentino|valkíria|veronique|versilius|viridiana)";
    namesDict.firstNames.w[3] = "(wes|wyn)";
    namesDict.firstNames.w[4] = "(wade|walt|ward|watt|wava|webb|west|will|wolf|wood|wren|wynn)";
    namesDict.firstNames.w[5] = "(waino|waiva|waldo|wally|wanda|wanni|wayne|wells|wendi|wendy|wilda|wiley|willa|willy|wilma|windy|woody|worth|wyatt|" +
                                "wylie|wyman|wynne)";
    namesDict.firstNames.w[6] = "(walden|walker|wallis|walter|walton|waneta|wanita|warner|warren|watson|waylon|waymon|weaver|weldon|welton|wendie|" +
                                "werner|wesley|weston|whelan|wilber|wilbur|wilkes|willem|willia|willie|willis|willow|wilmer|wilson|wilton|winema|" +
                                "winnie|winona|winter|winton|wisdom|witlee|wright|wynona)";
    namesDict.firstNames.w[7] = "(waleska|wallace|wardell|wassily|waverly|wayland|webster|wendell|westley|wheeler|whisper|whitley|whitman|whitney|" +
                                "wilbert|wilburn|wilford|wilfred|wilfrid|wilhelm|willard|willene|william|windell|winford|winfred|winslow|winston|" +
                                "woodrow|woolsey)";
    namesDict.firstNames.w[8] = "(waldemar|waltraud|wendelin|wilfredo|williams|winfield|winifred|wisteria|wolfgang)";
    namesDict.firstNames.w[9] = "(willodean|winnifred)";
    namesDict.firstNames.w[10] = "(washington|wellington|wilhelmina|wilhelmine|windradyne)";
    namesDict.firstNames.x[4] = "(xena|xoey)";
    namesDict.firstNames.x[5] = "(xaver|xenia|xenon)";
    namesDict.firstNames.x[6] = "(xander|xanthe|xavier|xerxes|xiaobo|ximena)";
    namesDict.firstNames.x[7] = "(xadrian|xanthia|xaviera|xeyenne|xiomara|xochitl|xzavier)";
    namesDict.firstNames.x[8] = "(xristina)";
    namesDict.firstNames.x[9] = "(xanthippe)";
    namesDict.firstNames.y[4] = "(yael|yair|yale|yana|yann|yeva|ylva|ynyr|yoki|yoko|york|yuki|yuri|yves)";
    namesDict.firstNames.y[5] = "(yaffa|yahir|yemen|yetta|yosef|yuriy|yusuf|yuval)";
    namesDict.firstNames.y[6] = "(yadiel|yadira|yancey|yanira|yannis|yarden|yareli|yasmin|yazmin|yehuda|yelena|yoshio|yriana|ysanne|ysella|yseult|" +
                                "ysolde|yvaine|yvette|yvonne)";
    namesDict.firstNames.y[7] = "(yahaira|yajaira|yamilet|yannick|yaretzi|yaritza|yasmeen|yasmina|yasmine|yesenia|yitzhak|yolanda|yolonda|yoselin|" +
                                "yoshiko|yuliana|yuridia)";
    namesDict.firstNames.y[8] = "(yessenia)";
    namesDict.firstNames.z[3] = "(zac|zeb|zed|zel|zen|zev|zia|zoe|zoi|zvi)";
    namesDict.firstNames.z[4] = "(zach|zack|zaid|zain|zane|zaor|zara|zayd|zeke|zena|zina|zion|zita|ziva|zoey|zoie|zola|zona|zora|zoya|zula|zuzu)";
    namesDict.firstNames.z[5] = "(zaden|zadok|zahra|zaida|zaide|zaire|zamia|zarek|zaria|zayne|zeely|zelda|zelia|zella|zelma|zenia|zenon|zetta|zhoee|" +
                                "zhyan|zilee|zilla|ziloh|zoila|zooey|zosia|zulma)";
    namesDict.firstNames.z[6] = "(zafira|zahara|zahava|zakary|zalika|zander|zariah|zavier|zayden|zenith|zephan|zephyn|zephyr|zillah|zinnia|zodiac|" +
                                "zodiax|zollie|zoltan|zosima|zuzana)";
    namesDict.firstNames.z[7] = "(zachary|zachery|zackary|zackery|zaltana|zaniyah|zebedee|zebulon|zemirah|zenaida|zenobia|zhlobko|zigmund|zinaida|" +
                                "zoraida|zoriana|zuleika)";
    namesDict.firstNames.z[8] = "(zebediah|zedekiah|zipporah)";
    namesDict.firstNames.z[9] = "(zachariah|zechariah|zephyrine)";
    namesDict.lastNames = [];
    namesDict.lastNames = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
    jQuery.each(namesDict.firstNames, function(i) {
        currentLetter = this;
        namesDict.lastNames[currentLetter] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14];
        jQuery.each(namesDict.lastNames[currentLetter], function(j) {
            namesDict.lastNames[currentLetter][j] = "";
        });
    });
    namesDict.lastNames.a[10] = "(armbruster|armendariz|armentrout|applewhite|altamirano)";
    namesDict.lastNames.a[11] = "(archambault|abercrombie)";
    namesDict.lastNames.a[3] = "(ahn|ali|ard|ash)";
    namesDict.lastNames.a[4] = "(ames|alva|alex|adam|agee|akin|alba|arce|amos|amin|ault|arms|argo|ayer|ashe|abel)";
    namesDict.lastNames.a[5] = "(ahern|aubin|audet|auger|alton|arndt|asher|aston|ayers|amaya|anaya|auten|avant|avery|ayres|alves|alvey|amaro|alden|" +
                                "abram|alsup|anton|anson|appel|abner|arias|amato|amick|andre|avila|alley|aaron|allen|albin|angus|adame|abell|ashby|" +
                                "ahner|abney|apple|arena|akers|alger|allan|angel|arana|ahmad|annis|acord|abbey|autry|artis|askew|ahmed|avina|acuna|" +
                                "angle|ables|ayala|acree|adair|aiken|agnew|acton|acker|abreu|akins|adams|adler)";
    namesDict.lastNames.a[6] = "(arroyo|allain|alfred|armijo|abeyta|ashton|arnold|aguayo|ashley|aiello|andrus|asbury|alanis|angelo|angell|albers|" +
                                "armour|alaniz|aquino|ansley|altman|aponte|abrams|archie|anglin|ardoin|arenas|aranda|araujo|angulo|archer|acosta|" +
                                "abbate|avelar|amador|alonzo|arruda|agosto|arnett|alfaro|aragon|aucoin|alcorn|adkins|abbott|allman|ackley|august|" +
                                "austin|autrey|avalos|adorno|atkins|atwell|aikens|adrian|abrego|arthur|aguiar|ahrens|aviles|aycock|ayotte|andrew|" +
                                "amaral|allard|ammons|alcala|absher|alford|adcock|alicea|adames|alessi|alston|atwood|aleman|almond|allred|ambriz|" +
                                "alonso|anders|andres|albert|araiza|andino|alfano)";
    namesDict.lastNames.a[7] = "(arriaga|attaway|atwater|anthony|alarcon|antonio|almonte|arteaga|aronson|averill|alcaraz|arreola|ashmore|atencio|" +
                                "alverez|ashburn|arriola|abraham|aguirre|aldrich|addison|adamson|andrade|alvarez|ashford|acevedo|almaraz|almeida|" +
                                "allison|almanza|aguilar|allgood|appling|alleman|alleyne|azevedo|andrews|arevalo|andress|ambrose|alfonso|argueta|" +
                                "atchley|alberts|apodaca|angeles|audette|amerson|appleby|antoine|armenta)";
    namesDict.lastNames.a[8] = "(arguello|ackerman|anderton|arbuckle|amundson|alderson|arellano|aparicio|alderman|aguilera|ashworth|armstead|anderson|" +
                                "abramson|anguiano|andersen|arbogast|alcantar|appleton|aldridge|atkinson|armitage|atherton|andresen|ashcraft|albrecht|" +
                                "alvarado|albright|arrowood|abdullah|albanese|atchison)";
    namesDict.lastNames.a[9] = "(abernathy|addington|arrington|albertson|armstrong|arsenault|applegate|alcantara|alejandro|alexander|archuleta|" +
                                "archibald|albritton|augustine|ainsworth|arceneaux|arredondo)";
    namesDict.lastNames.b[10] = "(barrientos|barrington|batchelder|beauregard|betancourt|billington|birchfield|birmingham|blackshear|blackstock|" +
                                "blanchette|bloodworth|bloomfield|boatwright|brewington|broadwater|brookshire|brotherton|brownfield|buckingham|" +
                                "buffington|bullington|bumgardner|burchfield|burkhalter|burkholder|burmeister|bustamante)";
    namesDict.lastNames.b[11] = "(ballesteros|bartholomew|baskerville|baumgardner|baumgartner|bettencourt|biggerstaff|billingsley|bissonnette|" +
                                "blankenship|braithwaite|brandenburg|brockington|butterfield)";
    namesDict.lastNames.b[12] = "(breckenridge)";
    namesDict.lastNames.b[2] = "(ba)";
    namesDict.lastNames.b[3] = "(bay|bey|bly|box|bui)";
    namesDict.lastNames.b[4] = "(brim|bolt|bish|bass|bibb|betz|bond|bias|ball|bice|bove|buck|bowe|bard|bare|bott|boss|bair|bono|bost|bane|berg|" +
                                "bill|bock|bone|beck|bear|bird|book|blum|beer|blue|borg|belt|butt|burg|bunn|bell|bull|buie|bump|behr|bush|burr|" +
                                "buss|bess|burt|byrd|blow|burk|bash|babb|belk|boyd|bach|best|baer|baez|bohn|bing|benz|bain|bahr|baum|beal|born|" +
                                "bays|benn|baca|barr|bugg|bobo|bean|bode|beam|budd|back|bray)";
    namesDict.lastNames.b[5] = "(baber|babin|bacon|bader|baeza|bagby|baier|baily|baird|baker|balch|bales|banda|bandy|banks|banta|baran|barba|barns|" +
                                "baron|barry|barth|bartz|basso|bates|batey|batts|bauer|baugh|bayer|bayne|beach|beale|beall|beals|beane|beard|beaty|" +
                                "beebe|beech|beers|beery|begay|beggs|belle|bello|bemis|benge|bentz|berry|betts|beyer|bibbs|bible|biggs|biles|bills|" +
                                "binns|birch|bixby|black|blain|blair|blais|blake|bland|blank|bliss|block|blood|bloom|blume|blunt|board|boden|boehm|" +
                                "bogan|boger|boggs|bogle|bolen|boles|bolin|bonds|boney|bonin|boone|booth|boren|bosch|botts|bourg|bowen|bower|bowes|" +
                                "bowie|boyce|boyer|boyle|brace|bracy|brady|bragg|brake|brand|brann|brant|braud|braun|bravo|breen|brehm|brent|brett|" +
                                "brian|brice|brien|brill|brink|brito|britt|brock|brody|brook|broom|brown|bruce|bruno|bruns|brush|bryan|bryce|budde|" +
                                "buell|bueno|buggs|bunch|bundy|burch|burge|burke|burks|burns|busby|busch|busse|butts|byars|bybee|byers|byler|bynum|" +
                                "byrne|byron|byrum)";
    namesDict.lastNames.b[6] = "(backer|backus|badger|bagley|bahena|bailey|baines|ballew|ballou|banker|banner|bannon|barbee|barber|barden|barela|" +
                                "barger|barham|barker|barlow|barner|barnes|barney|barnum|barone|barron|barros|barrow|bartel|barton|basham|bashaw|" +
                                "basile|baskin|batson|batten|battle|baucom|bauman|baxley|baxter|baylor|beaman|beamon|beason|beaton|beatty|beaver|" +
                                "becker|becnel|bedard|bedell|beeler|beeman|beeson|begley|belden|beller|belton|bender|benham|benner|bennet|benoit|" +
                                "benson|benton|berard|bergen|berger|bergin|berlin|berman|bernal|berndt|berube|bethea|bethel|bettis|bevins|bianco|" +
                                "bickel|biddle|bieber|bigham|bigler|binder|binion|bishop|bisson|bivens|bivins|bixler|blaine|blanco|blanks|blazer|" +
                                "blount|blythe|boddie|bodine|bogart|boland|bolden|bolduc|bolick|boling|bolton|bonham|bonner|bonney|booher|booker|" +
                                "boothe|boozer|borden|borges|boring|bosley|bostic|boston|bounds|bourne|boutin|bouton|boutte|bowden|bowens|bowers|" +
                                "bowler|bowles|bowlin|bowman|bowser|bowyer|boyett|boykin|boylan|boyles|bracey|braden|braley|branch|brandt|branum|" +
                                "brauer|brazil|breaux|bremer|breton|brewer|bridge|briggs|bright|briley|brodie|brogan|brooke|brooks|broome|brophy|" +
                                "brower|browne|bruner|brunet|bruton|bryant|bryson|bucher|buford|buller|bulter|bunker|bunton|burden|burger|burgin|" +
                                "burgos|burkey|burley|burney|burris|burrow|burrus|burson|burton|bushey|bussey|bustos|butler|button|buxton|byerly|" +
                                "byrnes)";
    namesDict.lastNames.b[7] = "(babbitt|babcock|bachman|backman|badillo|baggett|bagwell|baldwin|ballard|barajas|barbosa|barbour|barboza|barclay|" +
                                "barkley|barnard|barnett|barraza|barrera|barreto|barrett|barrier|barrios|barrows|bartels|bartley|bassett|bastian|" +
                                "bateman|batista|batiste|battles|baugher|baumann|bayless|bearden|beasley|beattie|beaudry|beavers|becerra|bechtel|" +
                                "beckett|beckham|beckley|beckman|bedford|bedwell|beecher|behrens|belcher|belisle|bellamy|bellows|beltran|benally|" +
                                "benford|benitez|bennett|bentley|bergman|berkley|bernard|bernier|berrios|bertram|beverly|bianchi|bidwell|bierman|" +
                                "bigelow|biggers|billiot|billups|binette|bingham|binkley|bissell|bittner|blakely|blalock|blanton|bledsoe|blevins|" +
                                "blocker|bloomer|boatman|bobbitt|boggess|bolanos|bolding|bolling|bonilla|bonnell|bonnett|borders|borrego|bostick|" +
                                "boswell|botello|bottoms|boucher|bouldin|bourque|bowling|boyette|boykins|boynton|bozarth|bozeman|bracken|bradley|" +
                                "brandon|branham|brannan|brannon|branson|branton|brasher|bratton|brawley|brawner|braxton|breault|breeden|breland|" +
                                "brennan|brenner|breunig|brewton|bricker|bridges|brigham|brinson|briones|briscoe|briseno|brister|bristol|bristow|" +
                                "britton|brodeur|brogdon|bromley|bronson|brooker|browder|broyles|brumley|brunner|brunson|buckles|buckley|buckman|" +
                                "buckner|buehler|bullard|bullins|bullock|bunnell|bunting|burbank|burcham|burdett|burdick|burdine|burford|burgess|" +
                                "burgett|burkett|burnell|burnett|burnham|burrell|burress|burrows|burwell|bushman|bussell|butcher|butters|buzzell)";
    namesDict.lastNames.b[8] = "(balderas|baltazar|bancroft|banister|bankston|banuelos|baptiste|barbieri|barfield|barhorst|barnette|barnhart|" +
                                "barnhill|barnwell|barragan|bartlett|baughman|bautista|beaudoin|beaulieu|bechtold|beckford|beckwith|bejarano|" +
                                "belanger|benedict|benfield|benjamin|bergeron|berglund|bergmann|bermudez|bernardo|berryman|bertrand|bessette|" +
                                "bickford|billings|bilodeau|birdsong|bischoff|blackman|blackmon|blakeney|blanding|blaylock|blessing|blizzard|" +
                                "blodgett|boardman|bohannon|boisvert|bolinger|bordelon|borowski|bostwick|bosworth|bouchard|boudreau|boughton|" +
                                "bourassa|bousquet|boutwell|brackett|bradbury|braddock|bradford|bradshaw|bramlett|brantley|brashear|braswell|" +
                                "bratcher|breeding|brewster|brinkley|brinkman|brittain|broadnax|broadway|brockman|brockway|brookins|brothers|" +
                                "brownell|browning|brownlee|brubaker|brummett|brundage|brunelle|buchanan|buchholz|burchett|burdette|burkhart|" +
                                "burleigh|burleson|burnette|burnside|bushnell|byington)";
    namesDict.lastNames.b[9] = "(babineaux|baldridge|ballenger|ballinger|bannister|barksdale|barringer|batchelor|battaglia|beardsley|beauchamp|" +
                                "bellinger|benavides|benavidez|benedetto|benefield|bergstrom|berkowitz|bernhardt|bernstein|berryhill|beveridge|" +
                                "blackburn|blackford|blackmore|blackwell|blackwood|blaisdell|blanchard|boatright|bocanegra|boettcher|bojorquez|" +
                                "bollinger|borkowski|boudreaux|bradberry|bradfield|breedlove|bridgeman|broderick|broughton|broussard|brumbaugh|" +
                                "brumfield|bumgarner|burkhardt|burroughs)";
    namesDict.lastNames.c[10] = "(candelaria|candelario|carmichael|carrington|carruthers|cartwright|castellano|chamberlin|chancellor|churchwell|" +
                                "concepcion|cornelison|cottingham|countryman|crittenden|culbertson|cunningham)";
    namesDict.lastNames.c[11] = "(castellanos|castleberry|chamberlain|christensen|christenson|christopher|constantine|constantino|covarrubias|" +
                                "crutchfield)";
    namesDict.lastNames.c[12] = "(carrasquillo|christiansen|christianson)";
    namesDict.lastNames.c[13] = "(christopherso)";
    namesDict.lastNames.c[3] = "(cao|cha|chi|cho|chu|coe|cox|coy|cyr)";
    namesDict.lastNames.c[4] = "(core|cave|clem|chau|cano|cade|chun|choi|camp|cobb|corn|ceja|clay|cook|chiu|chen|carr|cass|chan|cupp|chee|crim|" +
                                "carl|coon|cann|cate|chow|choe|crow|cohn|croy|cool|conn|chew|cruz|cork|cote|cato|call|card|cary|cage|cole|cady|" +
                                "cain|chin|cota|culp|caro|cory|chou|cram|curl|chao|cash|cope|cody|crum|cone)";
    namesDict.lastNames.c[5] = "(cuomo|cates|clary|colby|chick|caron|cerda|cater|chong|chism|clark|cronk|carty|cecil|chang|chapa|chinn|casas|crook|" +
                                "casey|cyrus|cheng|clare|clapp|ching|casto|chase|cisco|crain|cooke|claar|craft|caton|calvo|cruse|cantu|covey|corey|" +
                                "cooks|conte|cross|cress|coles|cotto|cobos|colin|caban|colon|comer|crabb|craig|cover|child|creel|crane|conti|combs|" +
                                "croom|cason|coons|crump|croft|crowe|coyne|coyle|cable|cowan|cheek|click|coney|cofer|chung|clair|cloud|creed|crews|" +
                                "costa|cosme|clyde|cobbs|coble|coker|corum|curry|canty|coats|capps|close|couch|clift|cline|crisp|cowen|cagle|conde|" +
                                "coley|crist|corso|cohen|clegg|carey|cosby|criss)";
    namesDict.lastNames.c[6] = "(cotten|chasse|copper|cathey|cottle|crouch|cotton|cooper|counts|culler|chapin|campos|corson|cuevas|cotter|corral|" +
                                "cousin|cheeks|corbin|covert|cosper|coston|corder|chaves|chavis|corley|corwin|chance|coburn|crooks|cribbs|coates|" +
                                "cimino|collin|cowley|craven|coffee|coffey|crespo|clough|crites|connor|cleary|clouse|cromer|clarke|chiles|creech|" +
                                "cruise|childs|colton|conner|conrad|coomer|cowart|cowles|cowden|coombs|cramer|conger|crosby|carson|colter|conlon|" +
                                "cowans|crouse|comeau|condon|callis|camara|camper|calvin|conroy|cannon|carman|cullen|chaney|cronin|cadena|cahill|" +
                                "caskey|cabral|callan|callen|cairns|cooley|carrol|canady|carney|carnes|carter|causey|culver|colson|cantor|carden|" +
                                "cancel|colley|caputo|carley|carlos|carder|church|cheney|cepeda|chafin|canter|cozart|christ|cowell|conway|conant|" +
                                "cortes|coward|curran|colman|cooney|coffin|corona|cahoon|carver|choate|cutler|crider|castor|canada|clancy|calder|" +
                                "correa|craver|custer|cortez|cheung|crotty|capers|carlin|conley|capone|cordes|curley|carper|curtis|caudle|catron|" +
                                "caruso|cherry|chacon|colvin|chavez|curtin|caesar|currin|currie|copley|cutter|cardin|cusick|castro|catlin|caston|" +
                                "cedeno|curiel|cawley|castle|center|chabot|conlin|casper)";
    namesDict.lastNames.c[7] = "(carruth|connell|cambell|conners|clyburn|collier|chester|conover|connors|cintron|cushing|colwell|cedillo|crowder|" +
                                "comeaux|cazares|charles|cardoza|carlton|colunga|creamer|camacho|charley|chaffin|conklin|casteel|clemmer|crafton|" +
                                "cameron|cumming|cabrera|cordova|chesser|cornell|chapman|chatman|carrico|chauvin|corbitt|cordero|caudill|cordell|" +
                                "carrell|corliss|couture|courson|cornett|chaplin|chatham|cornejo|croteau|cormier|claxton|clemens|crumley|chaffee|" +
                                "conaway|conwell|cummins|coulson|council|curtiss|cushman|chancey|crocker|clifton|coppola|currier|caddell|cooksey|" +
                                "crozier|cundiff|cassell|cargill|cannady|cardona|clement|corbett|carlson|casiano|carillo|carlile|clayton|clapper|" +
                                "cashman|clemons|collard|clinton|crowley|calhoun|caraway|crowell|carbone|cassidy|cothran|chumley|clanton|carrier|" +
                                "carrion|casares|chisolm|carroll|christy|cropper|charron|clausen|carreon|carlyle|carmack|claudio|carrera|carrero|" +
                                "carmona|conyers|cofield|caceres|coleman|colbert|clawson|collado|coffman|chipman|caldera|colella|cavazos|colburn|" +
                                "casarez|collins|cleaver|colston|centeno|colombo|collett|collazo|chilton|cuellar|cureton|caswell|catlett|cassady|" +
                                "cochran|coulter|crayton|canales|crawley|correia|coakley|calkins|correll|colucci|cornish|carmody|cravens|compton|" +
                                "calvert|coggins|cousins|cauthen)";
    namesDict.lastNames.c[8] = "(calderon|caldwell|callahan|callaway|callison|calloway|calvillo|campbell|canfield|cantrell|cantwell|carbajal|" +
                                "carbaugh|cardenas|cardinal|cardwell|carleton|carlisle|carnahan|carranza|carrasco|carraway|carrigan|carrillo|" +
                                "carswell|carvajal|carvalho|casanova|casillas|castillo|catalano|cathcart|cavender|caviness|ceballos|chadwick|" +
                                "chaisson|chalmers|chambers|chamblee|chamness|champion|champlin|chandler|chappell|charette|charlton|chartier|" +
                                "chastain|chasteen|cheatham|chenault|chestnut|childers|chisholm|chitwood|chrisman|christie|cisneros|clarkson|" +
                                "claycomb|claypool|cleghorn|clemente|clements|clemmons|clifford|cloutier|cochrane|cockrell|collette|colquitt|" +
                                "comstock|connelly|connolly|constant|converse|copeland|corcoran|cordeiro|cornwell|coronado|corrales|corrigan|" +
                                "cosgrove|costello|cottrell|coughlin|coulombe|courtney|crabtree|craddock|crandall|crandell|cranford|crawford|" +
                                "crenshaw|criswell|crockett|cromwell|crossley|crossman|crumpler|crumpton|crutcher|culbreth|cummings)";
    namesDict.lastNames.c[9] = "(caballero|calabrese|callaghan|callender|camarillo|caraballo|carothers|carpenter|cartagena|caruthers|castaneda|" +
                                "castleman|cavanaugh|cervantes|cervantez|chambless|chambliss|champagne|chavarria|chenoweth|chevalier|childress|" +
                                "chouinard|christian|christman|christmas|churchill|claypoole|cleveland|clevenger|cockerham|contreras|cornelius|" +
                                "corriveau|covington|creekmore|creighton|crossland|culpepper)";
    namesDict.lastNames.d[10] = "(delafuente|delgadillo|desjardins|desrochers|desrosiers|dillingham|dombrowski)";
    namesDict.lastNames.d[11] = "(dalessandro|delossantos)";
    namesDict.lastNames.d[2] = "(do)";
    namesDict.lastNames.d[3] = "(day|dee|dew|dix|doe|dow|dye)";
    namesDict.lastNames.d[4] = "(doak|deas|deal|dees|duke|duty|doan|dill|dyke|duda|duff|dash|doss|darr|derr|doty|dear|dunn|deck|doll|dick|dell|" +
                                "daye|dore|dion|dale|dinh|dana|dull|daly|dent|dial|dube|deen|dews|dean|dame|dowd|dodd|dyer|drew|dorr|durr|dahl|" +
                                "diaz|dang|drum|dove|delk|delp|dorn|dias|duck)";
    namesDict.lastNames.d[5] = "(davis|dumas|doyon|dudek|denny|drake|drain|denis|dugan|derby|deese|duhon|downs|dugas|doyle|desai|dover|derry|davey|" +
                                "depew|damon|dancy|duque|dixon|daily|daley|dyson|diego|dykes|dowdy|dewey|dobbs|dendy|david|diehl|dietz|deitz|drury|" +
                                "doane|duval|dabbs|dukes|devoe|dever|duran|diggs|duron|doerr|dawes|dolan|duong|dupre|deane|deans|dwyer|dicks|darby|" +
                                "dodds|doran|durst|dunne|duffy|dodge|dutra)";
    namesDict.lastNames.d[6] = "(dabney|daigle|dailey|dallas|dalton|damato|damico|damron|daniel|danley|danner|dansby|dardar|darden|darrow|dasher|" +
                                "davies|davila|dawson|dayton|deanda|deason|deaton|deboer|debose|decker|dehart|delano|deleon|delong|delrio|deluca|" +
                                "deluna|dement|demers|deming|demoss|denham|denman|denney|dennis|denson|denton|derosa|devine|devito|devlin|devore|" +
                                "dewitt|dexter|dibble|dicken|dickey|dilley|dillon|dillow|dingle|dionne|dixson|dobson|doctor|dodson|dollar|donald|" +
                                "donato|donley|donner|dooley|dorman|dorris|dorsey|dortch|dotson|doucet|dowden|dowell|downer|downes|downey|dozier|" +
                                "draper|dreher|dreyer|driver|dryden|duarte|dubois|dubose|dudley|duenas|duffey|duggan|dugger|dumont|dunbar|duncan|" +
                                "dunham|dunkin|dunkle|dunlap|dunlop|dunson|dunton|dupont|dupree|duprey|dupuis|durand|durant|durbin|durden|durfee|" +
                                "durham|durkee|durkin|dustin|dutton|duvall|dvorak)";
    namesDict.lastNames.d[7] = "(dacosta|daggett|dameron|dandrea|dangelo|daniels|darling|darnell|dasilva|davison|dawkins|dearing|deberry|decarlo|" +
                                "deckard|decosta|deering|dehaven|dejesus|delaney|delapaz|delgado|delisle|deloach|demarco|demello|dempsey|denison|" +
                                "dennard|denning|derrick|desilva|desmond|despain|deutsch|deville|devries|deweese|deyoung|diamond|dicarlo|dickens|" +
                                "dickman|dickson|dillard|dillion|dillman|dingess|dingman|dinkins|dishman|dobbins|dockery|doering|doggett|doherty|" +
                                "domingo|donahue|donnell|donohue|donovan|dorsett|doughty|douglas|dowdell|dowling|downing|drayton|drennan|duckett|" +
                                "dulaney|dunagan|dunaway|dunford|dunning|dunston|durrett|dutcher|dykstra)";
    namesDict.lastNames.d[8] = "(dahlgren|dalessio|danforth|dantzler|daughtry|davidson|deangelo|dearborn|decastro|decoteau|defelice|deguzman|" +
                                "delacruz|delarosa|delvalle|dennison|densmore|depriest|derosier|desantis|desimone|dietrich|dilworth|dimaggio|" +
                                "dinsmore|dipietro|dominick|donnelly|donofrio|doucette|douglass|dressler|driggers|driscoll|driskell|drummond|" +
                                "ducharme|dufresne|duquette)";
    namesDict.lastNames.d[9] = "(dagostino|dalrymple|dandridge|danielson|daugherty|davenport|deangelis|delagarza|delatorre|dellinger|desmarais|" +
                                "destefano|dickenson|dickerson|dickinson|distefano|dominguez|dominquez|donaldson|doolittle|dougherty|duckworth|" +
                                "duplessis)";
    namesDict.lastNames.e[10] = "(easterling|echevarria|echeverria|engelhardt)";
    namesDict.lastNames.e[11] = "(evangelista)";
    namesDict.lastNames.e[12] = "(eichelberger)";
    namesDict.lastNames.e[3] = "(eby|eck|ely|eng|erb)";
    namesDict.lastNames.e[4] = "(eads|eady|earl|east|eddy|eden|edge|egan|elam|eley|enos|epps|eudy|exum)";
    namesDict.lastNames.e[5] = "(eades|eagan|eagle|earle|earls|early|eason|eaton|eaves|ebert|edens|edgar|edson|elder|elias|eller|ellis|elmer|elrod|" +
                                "embry|emery|emory|engel|engle|ennis|enoch|ernst|ervin|erwin|eskew|essex|estep|estes|etter|evans|evers|ewald|ewell|" +
                                "ewing|ezell)";
    namesDict.lastNames.e[6] = "(earley|easley|easter|easton|eberle|eberly|echols|eckert|eckman|eddins|edison|edmond|edward|egbert|eggers|eggert|" +
                                "ehlers|eicher|eidson|eiland|eldred|elkins|elliot|elmore|elston|elwell|elwood|embree|emmert|emmons|endres|engler|" +
                                "erdman|ernest|espino|eubank|eugene)";
    namesDict.lastNames.e[7] = "(earnest|eastman|eddings|edelman|edmonds|edmunds|edwards|ehrlich|eliason|elledge|elliott|ellison|emanuel|emerick|" +
                                "emerson|england|englert|english|enright|epstein|erdmann|ericson|erskine|escobar|esparza|espinal|estevez|estrada|" +
                                "eubanks|evenson|everett|everson)";
    namesDict.lastNames.e[8] = "(eastwood|eckhardt|eckstein|edgerton|edington|edmiston|edmonson|eldredge|eldridge|elizondo|ellinger|endicott|" +
                                "engstrom|enriquez|epperson|erickson|escobedo|eskridge|espinosa|espinoza|esposito|esquibel|esquivel|estrella|" +
                                "ethridge|everette|everhart|eversole)";
    namesDict.lastNames.e[9] = "(eberhardt|edelstein|edmondson|eggleston|eisenberg|ellingson|ellington|ellsworth|escalante|escamilla|estabrook|" +
                                "etheridge)";
    namesDict.lastNames.f[10] = "(farnsworth|farrington|fitzgerald|fredericks|funderburk)";
    namesDict.lastNames.f[11] = "(fitzpatrick|fitzsimmons|fortenberry|fredrickson)";
    namesDict.lastNames.f[12] = "(featherstone|frederickson)";
    namesDict.lastNames.f[3] = "(fay|fee|fix|fox|foy|fry)";
    namesDict.lastNames.f[4] = "(fain|fair|falk|fant|farr|fast|fell|fenn|fick|fife|fike|fine|fink|finn|fish|fisk|fite|fitz|fogg|folk|fong|ford|" +
                                "fore|fort|foss|free|frey|frye|fulk|fung|funk|furr)";
    namesDict.lastNames.f[5] = "(faber|fagan|fahey|falls|faria|faris|faulk|faust|fazio|fears|felix|felts|ferro|ferry|field|fikes|finch|fiore|" +
                                "fitch|fitts|flack|flagg|flatt|fleck|flick|flinn|flint|flood|flora|flory|floyd|flynn|fogel|fogle|foley|folse|" +
                                "foltz|foote|force|forde|foret|forte|foust|fouts|fraga|frame|frank|franz|freed|frias|frick|fried|friel|fries|" +
                                "frink|frith|fritz|frost|fryer|fuchs|fudge|fulks|fultz|fuqua|fusco)";
    namesDict.lastNames.f[6] = "(fabian|faison|falcon|fallon|fannin|farber|farias|farina|farkas|farley|farmer|farrar|farris|farrow|favela|favors|" +
                                "feeney|felder|felker|feller|felton|fender|fenner|fenton|ferrer|ferris|fetter|fidler|fields|fierro|finger|finley|" +
                                "finney|fisher|fleury|flores|florez|flower|folsom|forbes|forest|forman|forney|fortin|foster|fowler|fraley|france|" +
                                "franco|franke|franks|frantz|fraser|frazee|frazer|freese|french|freund|friday|friend|frisby|frisch|fritts|fugate|" +
                                "fuller|fulmer|fulton|furman)";
    namesDict.lastNames.f[7] = "(ferebee|farwell|foreman|frasier|frausto|fenwick|falcone|fennell|frazier|fischer|fussell|francis|fleming|farnham|" +
                                "farrell|fairley|furtado|ferland|fajardo|ferrara|frances|frankel|fulcher|feaster|fuentes|findley|fecteau|frisbie|" +
                                "franzen|freitag|fuhrman|fawcett|fellows|fortier|futrell|feldman|fleenor|fancher|fogarty|fanning|freeman|fordham|" +
                                "furlong|ferrell|ferrari|fassett|forster|forsyth|fanelli|fortson|ferraro|fortner|fortney|fontana|fortune|freitas|" +
                                "fonseca|fowlkes|friesen|findlay|forrest|fishman|fiedler|fincher|fielder|fulford|fullmer|flowers|frawley|fifield)";
    namesDict.lastNames.f[8] = "(falgoust|faulkner|federico|ferguson|ferrante|ferreira|fielding|figueroa|fillmore|finnegan|fitzhugh|flaherty|" +
                                "flanagan|flanders|flanigan|flannery|flemming|fletcher|florence|flournoy|fontaine|fontenot|forester|forsberg|" +
                                "forsythe|fountain|fournier|foxworth|francois|franklin|fredette|fredrick|freedman|freeland|friedman|frierson|" +
                                "frizzell)";
    namesDict.lastNames.f[9] = "(fairbanks|fairchild|faircloth|feliciano|fernandes|fernandez|fitzwater|fleetwood|forrester|francisco|frechette|" +
                                "frederick|friedrich|fulkerson|fullerton)";
    namesDict.lastNames.g[10] = "(gilbertson|goldsberry|greathouse|greenfield)";
    namesDict.lastNames.g[3] = "(gay|gee|gil|guy)";
    namesDict.lastNames.g[4] = "(gage|gale|gall|gann|gant|gary|gass|gaul|geer|getz|gill|ginn|gish|gist|goad|goff|gold|good|gore|goss|gott|gove|" +
                                "graf|gray|grey|grim|grow|guay|gunn|gwin)";
    namesDict.lastNames.g[5] = "(gabel|gable|gaddy|gagne|galan|gallo|gamez|gandy|gantt|gaona|garay|garth|garza|gates|gatto|gault|gause|gavin|gayle|" +
                                "geary|geist|geter|geyer|gibbs|giese|giles|giron|glass|glaze|glenn|glick|glynn|gober|goble|godin|godoy|goetz|goins|" +
                                "gomes|gomez|gooch|goode|gordy|gough|gould|govan|gowen|gower|grace|grady|graff|gragg|grant|grass|greco|green|greer|" +
                                "gregg|grice|grier|grigg|grimm|groce|groff|groom|grose|gross|groth|grove|grubb|grube|guess|guest|guido|guinn|gupta|" +
                                "guyer|gwinn)";
    namesDict.lastNames.g[6] = "(gordan|gillum|gracia|guerin|gainer|grimes|gurley|gilley|grooms|godwin|goebel|grillo|gurney|guerra|greene|griego|" +
                                "grubbs|guyton|guzman|goodin|gurule|goines|grande|gipson|grogan|girard|gilman|grider|gilpin|grover|gruber|guidry|" +
                                "glover|gorman|goulet|glaser|gorton|grundy|gamble|gannon|gorski|garber|goings|gammon|galvez|gusman|gamboa|galvin|" +
                                "garver|garris|gerdes|garica|gulley|gilson|garman|graves|garner|garmon|gordon|gailey|gainey|gaines|gagnon|gadson|" +
                                "gustin|gregor|gulick|galvan|gillis|gorham|gunter|golden|givens|gaitan|gaskin|gillen|gillam|george|gaynor|gerber|" +
                                "gerald|gentry|geiger|gehrke|geller|giroux|gilkey|garcia|gooden|giglio|griggs|gibson|groves|garvin|gilmer|godsey|" +
                                "gatlin|gerard|guffey|garvey|gallup|graham|gaddis|gaspar|gaston|german|graber|gayton|gaytan|gattis|gaudet|gaylor|" +
                                "grasso)";
    namesDict.lastNames.g[7] = "(garnett|griffis|gleason|granger|grajeda|gaskins|greeley|grissom|garland|guillen|granado|grammer|griffin|gillett|" +
                                "grenier|gabbard|griffen|griffey|greaves|goddard|grisham|guevara|grigsby|gehring|grayson|gallego|gamache|gravely|" +
                                "gullett|guertin|goodell|gregory|gresham|grizzle|guarino|gervais|garibay|glisson|godfrey|greiner|gartner|glasser|" +
                                "garrett|garrity|gentile|galarza|goldman|golding|goforth|godinez|galindo|gallant|gilmore|glidden|germany|gillman|" +
                                "germain|gifford|gillard|gilliam|gaspard|gatling|gittens|gladney|gebhart|geisler|gladden|giddens|gaylord|goolsby|" +
                                "goodman|goodwin|gaskill|guthrie|gurrola|goodson|gendron|gossett|gosnell|gaither|gardner|garrick|gilbert|gabriel|" +
                                "goodale|gourley|gaffney|gribble|goodall|garrido|gooding|gunther|gerlach|gibbons|glasgow)";
    namesDict.lastNames.g[8] = "(gallaher|gallardo|gallegos|galloway|gambrell|gardiner|garfield|garrison|gastelum|gatewood|gaudette|gauthier|" +
                                "gearhart|genovese|gerhardt|giddings|gillette|gilliard|gilligan|gilreath|gilstrap|ginsberg|giordano|goldberg|" +
                                "gonzales|gonzalez|goodrich|gosselin|gottlieb|granados|grantham|graybill|graziano|greenlee|greenway|gregoire|" +
                                "griffith|grijalva|grimmett|grimsley|griswold|grossman|guajardo|guardado|guenther|guerrero|guillory|gulledge)";
    namesDict.lastNames.g[9] = "(galbraith|galbreath|gallagher|garretson|gilbreath|gilchrist|gillespie|gilliland|gillispie|glasscock|glidewell|" +
                                "goldsmith|goldstein|gonsalves|goodnight|grabowski|greenberg|greenleaf|greenwald|greenwell|greenwood|griffiths|" +
                                "gunderson|gustafson|gutierrez)";
    namesDict.lastNames.h[10] = "(hardcastle|harrington|hartsfield|hendershot|herrington|hildebrand|hollenbeck|hollifield|huddleston|huntington|" +
                                "hutcherson|hutchinson)";
    namesDict.lastNames.h[11] = "(hendrickson|hershberger|hildebrandt|hochstetler|hockenberry)";
    namesDict.lastNames.h[12] = "(higginbotham|hollingshead)";
    namesDict.lastNames.h[13] = "(hollingsworth)";
    namesDict.lastNames.h[2] = "(ha|ho|hu)";
    namesDict.lastNames.h[3] = "(ham|han|hay|her|hix|hom|hoy|hsu)";
    namesDict.lastNames.h[4] = "(haag|haas|hack|hage|hahn|hair|hake|hale|hall|hamm|hand|hang|hann|hare|haro|harp|harr|hart|hash|hass|haug|haun|" +
                                "hawk|haws|hays|head|heck|heil|heim|hein|held|helm|herd|herr|hess|higa|high|hill|hipp|hite|hitt|hoag|hoch|hoey|" +
                                "hoff|hogg|hoke|holm|holt|hong|hood|hook|hope|hord|horn|houk|howe|hoyt|huey|huff|hull|hume|hung|hunt|hupp|hurd|" +
                                "hurt|huss|huth|hyde)";
    namesDict.lastNames.h[5] = "(haase|haber|hafer|hagan|hagen|hager|hague|haile|haire|hales|haley|hamby|hamel|hamer|hance|handy|hanes|haney|hanks|" +
                                "hanna|hardy|harms|harry|hasty|hatch|hauck|haupt|haven|hawes|hawks|hayes|hazel|hazen|heald|healy|heard|hearn|heath|" +
                                "hecht|hedge|heine|heinz|helms|henke|henry|heron|hesse|heyer|hiatt|hibbs|hicks|higgs|hight|hiles|hills|himes|hinds|" +
                                "hines|hintz|hirst|hixon|hoang|hoard|hobbs|hodge|hofer|hogan|hogue|holly|holst|holtz|homan|homer|honea|hooks|hoppe|" +
                                "horan|horne|horst|hosey|houck|hough|houle|house|hovis|howes|howze|hoyle|huang|hubbs|huber|hudak|hulse|humes|hurst|" +
                                "hutto|huynh|hwang|hyatt|hyden|hyder|hyman|hynes)";
    namesDict.lastNames.h[6] = "(hacker|haddad|hadden|haddix|hadley|hagans|hagler|haight|hailey|haines|haller|halley|halpin|halsey|halter|hamann|" +
                                "hamill|hamlin|hammer|hammon|hanley|hanlon|hannah|hannan|hannon|hansel|hansen|hanson|harbin|hardee|harden|harder|" +
                                "hardie|hardin|hargis|harker|harlan|harley|harlow|harman|harmon|harney|harold|harper|harris|harrod|harter|hartle|" +
                                "harvey|hassan|hasson|hatley|hatten|hatton|haugen|hauser|havens|hawkes|hawley|hayden|haynes|haynie|hazard|healey|" +
                                "hearne|heaton|hebert|hecker|hector|hedges|heflin|hefner|heintz|heiser|heller|helman|helmer|helton|hendon|hendry|" +
                                "henkel|henley|henson|herald|herbst|herman|herold|herren|herrin|herron|hersey|hertel|herzog|hester|hewett|hewitt|" +
                                "hickey|higdon|hiller|hillis|hilton|hinkle|hinman|hinson|hinton|hirsch|hixson|hobart|hobson|hodges|hodson|hoffer|" +
                                "holden|holder|hollar|holler|holley|hollis|holman|holmes|holton|holzer|hooker|hooper|hooten|hoover|hopper|hopson|" +
                                "horner|horton|houser|howard|howell|hubert|hudson|huerta|hughes|hughey|hulett|hulsey|humble|hummel|hunley|hunter|" +
                                "hurdle|hurley|huskey|hussey|husted|huston|hutson|hutton|hyland|hylton)";
    namesDict.lastNames.h[7] = "(hackett|hackler|hackman|hackney|haddock|hageman|hagerty|haggard|halbert|halcomb|halford|hallett|hallman|hallock|" +
                                "halpern|hamblin|hamlett|hammack|hammett|hammock|hammond|hammons|hampton|hamrick|hancock|handley|hankins|harbour|" +
                                "harding|hardman|hargett|harkins|harless|harness|harrell|hartley|hartman|hartung|hartwig|harvell|harwell|harwood|" +
                                "haskell|haskins|hassell|hatcher|hawkins|haworth|haygood|hayward|haywood|hazlett|hazzard|headley|heckman|hedrick|" +
                                "heffner|heilman|heisler|hellman|helmick|hembree|hendley|hendren|hendrix|henning|henshaw|hensley|herbert|heredia|" +
                                "hermann|herndon|herrera|herrick|herring|hershey|hetrick|hewlett|heyward|hibbard|hickman|hickson|hidalgo|higgins|" +
                                "hilbert|hillard|hillman|hindman|hinkley|hinshaw|hockett|hodgson|hoffman|hofmann|hoggard|holbert|holcomb|holguin|" +
                                "holiday|holland|hollins|holston|honaker|hopkins|horning|hornsby|horsley|horvath|hoskins|housley|houston|howland|" +
                                "howlett|hubbard|hubbell|huckaby|hudgens|hudgins|hudnall|huebner|huffman|hufford|huggins|hulbert|hundley|huntley|" +
                                "hurtado)";
    namesDict.lastNames.h[8] = "(hagerman|haggerty|hairston|halliday|hallmark|halloran|halstead|hambrick|hamilton|hammonds|hanrahan|harbison|" +
                                "hardaway|hardeman|hardesty|hardiman|hardison|hardwick|hargrave|hargrove|harkness|harrigan|harriman|harrison|" +
                                "hartford|hartmann|hartnett|hartsell|hartsock|hartwell|hartzell|hastings|hatchett|hatfield|hathaway|hathcock|" +
                                "hazelton|headrick|heinrich|hemphill|hendrick|hennessy|hereford|hernadez|herrmann|hildreth|hilliard|hinojosa|" +
                                "hoagland|hodgkins|hoffmann|holbrook|holcombe|holliday|holliman|holloman|holloway|holmberg|hornback|horowitz|" +
                                "houghton|howerton|hudspeth|humphrey|hunsaker|huntsman|hutchens|hutchins)";
    namesDict.lastNames.h[9] = "(hackworth|halverson|halvorson|harrelson|hartfield|hawthorne|hazelwood|hedgepeth|heffernan|hemingway|henderson|" +
                                "hendricks|hennessey|henninger|henriquez|hernandes|hernandez|hickerson|highsmith|hightower|hitchcock|hoelscher|" +
                                "holifield|hollander|hollinger|hollister|hollowell|holmquist|honeycutt|hostetler|hostetter|hotchkiss|humphreys|" +
                                "humphries|huneycutt|hutcheson|hutchings|hutchison)";
    namesDict.lastNames.i[3] = "(ide|ivy)";
    namesDict.lastNames.i[4] = "(imes|irby|isom|ison|ives|ivey|ivie|izzo)";
    namesDict.lastNames.i[5] = "(ingle|inman|irish|irons|irvin|irwin|isaac|isham|ivory)";
    namesDict.lastNames.i[6] = "(ibanez|ibarra|imhoff|ingram|irvine|irving|isaacs|isbell|israel)";
    namesDict.lastNames.i[7] = "(ibrahim|infante|ingalls|ireland|iverson)";
    namesDict.lastNames.i[8] = "(iglesias|ingraham|irizarry|isaacson|isenberg)";
    namesDict.lastNames.i[9] = "(ingersoll)";
    namesDict.lastNames.j[3] = "(jay|joe|joy)";
    namesDict.lastNames.j[4] = "(jack|jara|jean|jett|jobe|john|jone|jose|jost|juan|judd|jude|judy|jung|just)";
    namesDict.lastNames.j[5] = "(jacks|jacob|jaffe|jaime|james|janes|jason|jasso|jenks|jesse|jeter|jiles|jinks|johns|jolly|jonas|jones|jorge|" +
                                "joyce|judge)";
    namesDict.lastNames.j[6] = "(jacobo|jacobs|jacoby|jaeger|jahnke|jaimes|jansen|jaquez|jarman|jarmon|jarvis|jasper|javier|jaynes|jensen|jenson|" +
                                "jerome|jessen|jessie|jessup|jester|jewell|jewett|joiner|jolley|jordan|jordon|joseph|joslin|joyner|juarez|julian|" +
                                "justus)";
    namesDict.lastNames.j[7] = "(jackman|jackson|jacques|jameson|jamison|janssen|jardine|jarrell|jarrett|jeffers|jeffery|jeffrey|jemison|jenkins|" +
                                "jimenez|jiminez|johnsen|johnson|joubert|judkins|justice)";
    namesDict.lastNames.j[8] = "(jacobsen|jacobson|jamerson|jamieson|jauregui|jaworski|jeffcoat|jeffries|jennings|jernigan|jimerson|johansen|" +
                                "johanson|johnston)";
    namesDict.lastNames.j[9] = "(jablonski|jankowski|jaramillo|jefferies|jefferson|johnstone|jorgensen|jorgenson|josephson)";
    namesDict.lastNames.k[10] = "(kilpatrick|kuykendall)";
    namesDict.lastNames.k[11] = "(kirkpatrick)";
    namesDict.lastNames.k[12] = "(klingensmith)";
    namesDict.lastNames.k[13] = "(killingsworth)";
    namesDict.lastNames.k[3] = "(kay|kee|key|kim)";
    namesDict.lastNames.k[4] = "(kahl|kahn|kain|kane|kang|kapp|karl|karp|karr|kato|katz|kaye|kean|keck|keel|keen|keil|keim|kell|kemp|kent|kern|" +
                                "kerr|keys|khan|kidd|kiel|kile|king|kipp|kirk|kish|kite|klug|knox|koch|kohl|kohn|kolb|kong|koon|kopp|korn|koss|" +
                                "krug|kuhl|kuhn|kunz|kutz|kwan|kwon|kyle)";
    namesDict.lastNames.k[5] = "(karns|kautz|keane|keefe|keele|keene|kehoe|keith|kelly|kelso|kempf|kenny|kerby|kerns|keyes|kiger|kight|kimes|" +
                                "kirby|kiser|kitts|kizer|klatt|klaus|klein|kline|kling|klink|klotz|knapp|knoll|knopp|knott|koehn|koons|koski|" +
                                "kowal|kozak|kraft|kranz|kratz|kraus|krebs|kress|kroll|kruse|kuehn|kuhns|kumar|kuntz|kurtz|kyles|kyser)";
    namesDict.lastNames.k[6] = "(kahler|kaiser|kaplan|karnes|kasper|kasten|kaylor|kearns|kearse|keaton|keefer|keegan|keeler|keeley|keenan|keener|" +
                                "keeney|keeton|keiser|kellam|kellar|keller|kelley|kellum|kelsey|kemper|kenner|kenney|kennon|kenyon|kerley|kersey|" +
                                "kester|keyser|khoury|kibler|kidder|kiefer|kilmer|kimber|kimble|kimmel|kimsey|kimura|kinard|kinder|kinlaw|kinney|" +
                                "kinser|kinsey|kirsch|kittle|knight|knotts|kocher|koenig|kohler|koller|koonce|koontz|koster|kovach|kovacs|kramer|" +
                                "krantz|krause|krauss|kremer|kruger|kunkel|kunkle)";
    namesDict.lastNames.k[7] = "(kastner|kaufman|kearney|keating|keeling|keister|kellner|kellogg|kendall|kennard|kennedy|kershaw|kessler|ketcham|" +
                                "ketchum|kidwell|kieffer|kilburn|kilgore|killian|killion|kimball|kincaid|kindred|kingery|kinnard|kirkham|kirkman|" +
                                "kirksey|kistler|kitchen|klinger|knepper|knisley|knowles|knudsen|knudson|knutson|koehler|koerner|koester|kraemer|" +
                                "krieger|kroeger|krueger|kuhlman)";
    namesDict.lastNames.k[8] = "(kaminski|kauffman|kaufmann|kavanagh|kelleher|kendrick|kerrigan|killough|kimbrell|kingsley|kingston|kinsella|" +
                                "kirchner|kirkland|kirkwood|kitchens|kittrell|knighten|knighton|knowlton|kornegay|kowalski)";
    namesDict.lastNames.k[9] = "(kavanaugh|kellerman|kessinger|kimbrough|kingsbury|kirschner|kissinger|kobayashi|kowalczyk|kozlowski)";
    namesDict.lastNames.l[10] = "(lafontaine|lafountain|lamontagne|larochelle|lauderdale|leatherman|letourneau|litchfield|littlejohn|livingston|" +
                                "loudermilk)";
    namesDict.lastNames.l[11] = "(leatherwood|lewandowski|littlefield)";
    namesDict.lastNames.l[2] = "(le|li|lo|lu|ly)";
    namesDict.lastNames.l[3] = "(lai|lam|lau|law|lay|lea|lee|leo|lew|ley|lim|lin|liu|low|loy|lum|luu|lux)";
    namesDict.lastNames.l[4] = "(lacy|ladd|lahr|lail|lair|lake|lamb|lamm|lamp|land|lane|lang|lapp|lara|lark|lash|laws|lazo|leak|leal|lear|lees|" +
                                "legg|lehr|lent|lenz|leon|lett|levi|levy|lien|lima|lind|ling|link|linn|lira|list|lock|lohr|long|loos|lord|lott|" +
                                "love|lowe|loya|loyd|luce|luck|lugo|luis|luke|luna|lund|lunn|lupo|lusk|lutz|lyle|lynn|lyon)";
    namesDict.lastNames.l[5] = "(labbe|laboy|lacey|laine|laing|laird|lakey|lally|lamar|lampe|lance|landa|laney|lange|lantz|lanza|large|larry|larue|" +
                                "latta|lauer|lavin|layne|lazar|leach|leahy|leake|leary|leath|ledet|leech|leger|leigh|leija|leiva|lemay|lemke|lemon|" +
                                "lemos|lemus|lentz|leone|leong|lerma|leroy|leung|levin|lewin|lewis|leyva|liang|libby|light|ligon|liles|lilly|limon|" +
                                "lines|lloyd|locke|loera|logan|logue|lomas|lomax|loney|longo|loper|lopes|lopez|lough|louie|louis|lower|lowry|lucas|" +
                                "lucia|lucio|lucky|lujan|luker|lundy|luong|lutes|lyles|lyman|lynch|lyons|lytle)";
    namesDict.lastNames.l[6] = "(labrie|lackey|ladner|lafave|lajoie|lamont|lander|landes|landin|landis|landon|landry|langer|lanham|lanier|larkin|" +
                                "larosa|larose|larsen|larson|lasher|lasley|laster|latham|lavoie|lawler|lawlor|lawson|lawton|lawyer|layman|layton|" +
                                "lebron|lebrun|ledoux|leeper|lehman|leland|lemire|lemley|lemmon|lemons|lenard|lennon|lennox|lenoir|lepage|lerner|" +
                                "lesher|leslie|lester|levine|levitt|lilley|lillie|linden|linder|linker|linton|lipsey|lister|liston|little|litton|" +
                                "lively|llamas|loftin|loftis|lofton|loftus|lohman|lomeli|london|loomis|looney|looper|lorenz|loucks|lovato|lovell|" +
                                "lovely|lovett|loving|lowder|lowell|lowery|lowman|lowrey|lozada|lozano|lucero|lucier|luckey|ludwig|luster|luther|" +
                                "lykins)";
    namesDict.lastNames.l[7] = "(labelle|labonte|lacasse|lacombe|lacroix|lafleur|lalonde|lambert|lampkin|landers|landrum|langdon|langham|langley|" +
                                "lanning|laporte|largent|larkins|laroche|lasalle|lasater|lashley|lathrop|latimer|laurent|lavelle|lavigne|lawhorn|" +
                                "lawless|lazarus|leavitt|leblanc|leboeuf|leclair|leclerc|ledesma|ledezma|ledford|lefevre|leflore|leggett|legrand|" +
                                "lehmann|lejeune|lemieux|lemmons|lemoine|lenhart|leonard|lessard|liddell|liggett|liggins|lillard|linares|lincoln|" +
                                "lindley|lindner|lindsay|lindsey|linkous|lippert|lizotte|lockard|lockett|loggins|logsdon|lombard|lorenzo|lovejoy|" +
                                "lowther|luciano|luckett|ludwick|luevano|lumpkin|lussier)";
    namesDict.lastNames.l[8] = "(lachance|lafferty|laflamme|lafrance|landeros|landreth|langford|langlois|langston|lankford|lapierre|laplante|" +
                                "lapointe|larrabee|lassiter|laughlin|laureano|lavallee|lavalley|lavender|lavergne|lawrence|leathers|lecompte|" +
                                "lefebvre|leftwich|leighton|lemaster|leonardo|letendre|leverett|levesque|levinson|lheureux|lightner|lindberg|" +
                                "lindeman|lindgren|linville|lipscomb|littrell|lockhart|locklear|lockwood|loeffler|lombardi|lombardo|longoria|" +
                                "lovelace|lovelady|loveland|loveless|lundberg|lundgren|lunsford|luttrell)";
    namesDict.lastNames.l[9] = "(labrecque|laliberte|lamoureux|lancaster|lattimore|ledbetter|leibowitz|levasseur|lieberman|lightfoot|lindquist|" +
                                "lindstrom|lineberry|littleton|livengood|llewellyn|lockridge|lundquist)";
    namesDict.lastNames.m[10] = "(malinowski|manchester|manzanares|martindale|martinelli|mascarenas|massengale|mendenhall|merrifield|michaelson|" +
                                "miramontes|montelongo|montemayor|montenegro|montgomery|mulholland)";
    namesDict.lastNames.m[11] = "(morrissette)";
    namesDict.lastNames.m[12] = "(merriweather|middlebrooks)";
    namesDict.lastNames.m[2] = "(ma)";
    namesDict.lastNames.m[3] = "(mai|may|mix|moe|moy)";
    namesDict.lastNames.m[4] = "(maas|mabe|mace|mach|mack|macy|maes|main|maki|mann|mapp|mark|marr|mars|marx|mask|mast|mata|matz|maus|maya|maye|" +
                                "mayo|mays|maze|mead|meek|melo|mena|mesa|metz|meza|mick|mier|mims|mink|mize|mock|moen|mohr|moll|monk|moon|mora|" +
                                "more|moss|mota|mott|moua|moya|moye|mudd|muia|muir|mull|munn|muro|muse|muth|myer)";
    namesDict.lastNames.m[5] = "(mabry|macon|mader|magee|mahan|maher|mahon|maier|major|maley|malik|maloy|manis|manns|manor|manzo|mapes|maple|" +
                                "march|marek|mares|marin|marks|marra|marrs|marsh|marty|martz|mason|massa|masse|mateo|matos|matta|mauro|maxey|" +
                                "mayer|mayes|mayle|mazur|mazza|meade|means|mears|meeks|mehta|meier|mejia|mello|menke|meraz|merry|mertz|metts|" +
                                "meyer|miele|milam|milan|miles|miley|mills|milne|miner|mingo|minor|mintz|mixon|moats|mohan|money|monge|moniz|" +
                                "monte|moody|moore|moran|morel|morey|morin|morse|mosby|moser|moses|moten|moton|mount|mowry|moyer|muncy|mundy|" +
                                "muniz|munoz|munro|murry|music|myatt|myers|myles)";
    namesDict.lastNames.m[6] = "(macedo|macias|maciel|mackey|madden|maddox|maddux|madera|madore|madrid|madsen|magana|maggio|magill|mahler|mahone|" +
                                "majors|malave|malcom|malley|malloy|malone|mandel|maness|mangan|mangum|manion|manley|manson|manuel|maples|marble|" +
                                "marcum|marcus|marine|marino|marion|marker|markey|markle|markus|marler|marley|marlin|marlow|marrow|martel|martin|" +
                                "marvin|massey|massie|mastin|mather|mathes|mathew|mathis|matias|matney|matson|mattos|mattox|mauney|maupin|maurer|" +
                                "maxson|mayers|mayhew|meador|mecham|medina|medley|medlin|meehan|meeker|mejias|mellon|melton|melvin|menard|mendes|" +
                                "mendez|mercer|merida|merino|merkel|merkle|messer|meyers|michel|mickey|mickle|miguel|milano|millan|millar|miller|" +
                                "millet|milner|milton|mincey|minter|minton|mizell|mobley|modlin|mohler|mojica|molina|moller|molloy|molnar|monaco|" +
                                "monday|monger|monroe|monroy|monson|montes|montez|mooney|moorer|moreau|moreno|morgan|moritz|morley|morris|morrow|" +
                                "morton|mosely|mosher|mosier|mosley|motley|mounts|mouton|mowery|moxley|moyers|mulkey|mullen|muller|mullin|mullis|" +
                                "mulvey|munger|munroe|munson|murphy|murray|musick|musser|myrick)";
    namesDict.lastNames.m[7] = "(machado|macklin|madigan|madison|maestas|maggard|maguire|mahoney|malcolm|mallard|mallett|mallory|maloney|mancini|" +
                                "mancuso|mangrum|manning|mannino|mansour|manzano|marable|marcano|mariano|markham|markley|marlowe|marquez|marquis|" +
                                "marrero|marrufo|marston|martell|martens|martini|martino|martins|masters|matheny|mathers|mathews|mathias|mathieu|" +
                                "matlock|mattern|matthew|mattson|mauldin|maurice|maxwell|maynard|mayorga|meacham|meadows|meagher|medford|medlock|" +
                                "medrano|meekins|mefford|meister|melcher|mellott|melnick|mendoza|menefee|meneses|mercado|mercier|merrell|merrick|" +
                                "merrill|merritt|mertens|messick|messier|messina|messner|metcalf|metzger|metzler|michael|michaud|michell|michels|" +
                                "mickens|midkiff|milburn|milford|millard|million|millsap|minnick|miracle|miranda|mireles|mitchel|mitchem|mitchum|" +
                                "moeller|moffatt|moffett|moffitt|mohamed|monahan|montana|montano|montero|montiel|montoya|moorman|morales|moralez|" +
                                "moreira|morelli|morrell|morrill|moseley|moulton|mueller|mulcahy|mullens|mullins|mumford|munguia|murdoch|murdock|" +
                                "murillo|murphey|murrell)";
    namesDict.lastNames.m[8] = "(madrigal|magnuson|magruder|mahaffey|mallette|marchand|marchant|marchese|marcotte|marriott|marshall|martines|" +
                                "martinez|mashburn|matherly|matherne|matheson|mathison|matteson|matthews|mattison|maxfield|mayberry|mayfield|" +
                                "medeiros|medellin|melancon|melanson|melendez|menchaca|mendiola|menendez|merchant|mercurio|meredith|merriman|" +
                                "merryman|metcalfe|michaels|milligan|milliken|mitchell|mohammed|monaghan|moncrief|montague|montalvo|montanez|" +
                                "morehead|moreland|moriarty|morrison|mortimer|mosqueda|moultrie|moynihan|muhammad|mulligan|mullinax|murphree|" +
                                "musgrave|musgrove)";
    namesDict.lastNames.m[9] = "(maldonado|mansfield|marchetti|marinelli|markowitz|marquardt|marroquin|martineau|martinson|masterson|mathewson|" +
                                "mattingly|messenger|michalski|mickelson|middleton|mondragon|moorehead|morehouse|morrissey|mortensen|mortenson|" +
                                "murchison|musselman)";
    namesDict.lastNames.n[10] = "(napolitano|nottingham)";
    namesDict.lastNames.n[11] = "(nightingale)";
    namesDict.lastNames.n[2] = "(ng)";
    namesDict.lastNames.n[3] = "(new|nez|ngo|nix|noe|nye)";
    namesDict.lastNames.n[4] = "(nagy|nail|nall|nash|nava|nave|neal|neel|neff|neil|neri|nero|ness|nino|noah|noel|noll|nord|null|nunn|nutt)";
    namesDict.lastNames.n[5] = "(nagel|nagle|nance|nason|neace|neale|nealy|neary|neely|neese|neill|nelms|newby|nicol|niemi|nieto|nigro|niles|" +
                                "nixon|noble|nolan|nolen|nolte|north|novak|nowak|noyes|nunes|nunez)";
    namesDict.lastNames.n[6] = "(nabors|nadeau|najera|nakano|nalley|napier|napoli|napper|naquin|natale|nathan|nation|naylor|neeley|negron|nelsen|" +
                                "nelson|nemeth|nesbit|nester|nestor|neuman|nevels|nevins|newell|newlin|newman|newsom|newson|newton|nguyen|nickel|" +
                                "nieman|nieves|nissen|nobles|noland|noonan|norman|norris|norton|nowell|nowlin|nugent|nunley|nutter)";
    namesDict.lastNames.n[7] = "(naranjo|narvaez|nations|navarro|nazario|necaise|needham|negrete|neilson|nesbitt|nesmith|nettles|neumann|nevarez|" +
                                "neville|newcomb|newkirk|newland|newport|newsome|nichols|nickell|nickels|nickens|nickles|nicolas|nielsen|nielson|" +
                                "nilsson|nolasco|noriega|norvell|norwood|novotny|nowicki|numbers)";
    namesDict.lastNames.n[8] = "(nakamura|neubauer|newberry|newhouse|nicholas|nicholls|norfleet|northern|nunnally)";
    namesDict.lastNames.n[9] = "(natividad|navarrete|neighbors|nicholson|nickerson|nordstrom|northcutt)";
    namesDict.lastNames.o[10] = "(overstreet)";
    namesDict.lastNames.o[2] = "(oh)";
    namesDict.lastNames.o[3] = "(ong|orr|ott)";
    namesDict.lastNames.o[4] = "(oaks|ochs|oden|odom|odum|ogle|olds|olin|orta|orth|otis|otte|otto|owen)";
    namesDict.lastNames.o[5] = "(oakes|oates|oberg|ochoa|odell|ogden|ohara|ohare|ojeda|oliva|olive|olivo|olmos|olney|olsen|olson|omara|oneal|" +
                                "oneil|ortiz|orton|oshea|oster|osuna|otero|otten|oubre|owens|oxley|oyler|ozuna)";
    namesDict.lastNames.o[6] = "(oakley|obrian|obrien|obryan|ocampo|ocasio|offutt|ogburn|ogrady|okeefe|oldham|oleary|olguin|olivas|oliver|olvera|" +
                                "omeara|oneill|oquinn|orange|orcutt|ordway|orosco|orozco|ortega|ortego|osborn|osburn|osgood|osorio|osteen|oswald|" +
                                "oswalt|otoole|ousley|outlaw|ovalle|overby|owings|owsley|oxford)";
    namesDict.lastNames.o[7] = "(obryant|oconner|oconnor|oglesby|okelley|olinger|olivera|olivier|omalley|oquendo|ordonez|oreilly|orlando|ornelas|" +
                                "orourke|osborne|overman|overton)";
    namesDict.lastNames.o[8] = "(oconnell|odonnell|ogletree|oliphant|olivares|olivarez|oliveira|olmstead|orellana|osterman|ottinger)";
    namesDict.lastNames.o[9] = "(olszewski|ontiveros|ostrander|osullivan|ouellette)";
    namesDict.lastNames.p[10] = "(pellegrino|pennington|pilkington|plascencia|poindexter|provencher)";
    namesDict.lastNames.p[11] = "(pendergrass|porterfield|prendergast)";
    namesDict.lastNames.p[3] = "(pak|paz|poe)";
    namesDict.lastNames.p[4] = "(pace|pack|paez|page|palm|pang|papa|pape|pare|park|parr|pass|pate|paul|peak|peck|peek|peel|pena|penn|pepe|pete|" +
                                "pham|phan|pigg|pike|pina|pine|pino|pitt|pohl|polk|pond|pool|pope|popp|post|powe|pray|puga|pugh|pyle)";
    namesDict.lastNames.p[5] = "(pabon|pagan|paige|paine|palma|pardo|paris|parke|parks|parra|parry|patch|patel|paulk|payne|peace|peach|peake|" +
                                "pearl|pease|peavy|peden|pedro|peele|peery|pence|penny|pepin|percy|perea|peres|perez|perri|perry|peter|petry|" +
                                "petty|pfaff|pharr|piatt|pinto|piper|pires|pitre|pitts|place|plank|plant|platt|plaza|pless|plumb|pogue|ponce|" +
                                "poole|poore|posey|potts|power|prado|pratt|price|pride|prine|prior|pryor|purdy|pyles)";
    namesDict.lastNames.p[6] = "(packer|padron|pagano|palmer|palomo|pankey|pappas|paquin|pardue|parent|parham|parish|parisi|parker|parmer|parris|" +
                                "parson|partin|parton|pastor|patino|patten|patton|pauley|paulus|paxton|payton|pearce|pedigo|peeler|pegues|pelayo|" +
                                "pelkey|pelton|pender|penner|penney|penrod|penton|pepper|perdue|perrin|perron|person|peters|petrie|pettis|pettit|" +
                                "pettus|peyton|phelan|phelps|phifer|philip|phipps|piazza|picard|pickle|pieper|pierce|piercy|pierre|pillow|pinder|" +
                                "pineda|pinson|pipkin|pippin|pirtle|pisano|pitman|plante|player|poland|poling|polley|polson|ponder|pooler|porras|" +
                                "porter|portis|posada|poston|poteat|poteet|potter|poulin|poulos|pounds|powell|powers|prater|preece|priddy|priest|" +
                                "prieto|prince|probst|propst|proulx|prouty|pruett|pruitt|puente|pulido|pullen|pulley|pulver|purser|purvis|putman|" +
                                "putnam)";
    namesDict.lastNames.p[7] = "(pacheco|packard|paddock|padgett|padilla|painter|palacio|palermo|palmore|palumbo|pannell|pantoja|paradis|paredes|" +
                                "parkman|parnell|parrish|parrott|parsley|parsons|partain|partida|paschal|pascual|pastore|patrick|paulino|paulsen|" +
                                "paulson|paynter|peabody|peachey|peacock|pearman|pearson|peckham|pedraza|pedroza|peebles|peeples|peltier|pendley|" +
                                "penland|pennell|peoples|peppers|perales|peralta|perdomo|pereira|perkins|perlman|perrine|perrone|persaud|pettway|" +
                                "pfeffer|pfeifer|pfister|philips|phillip|philpot|pickard|pickens|pickett|pierson|pilcher|pilgrim|pinkham|pinkney|" +
                                "pitcher|pittman|pizarro|plourde|plowman|plumley|plummer|pointer|poirier|poisson|polanco|pollack|pollard|pollock|" +
                                "pomeroy|poynter|prather|presley|preston|prevost|prewitt|pridgen|pringle|proctor|prosser|provost|puckett|pulliam|" +
                                "purcell|purnell|pursley|puryear)";
    namesDict.lastNames.p[8] = "(palacios|palmieri|palomino|paniagua|paquette|paradise|paschall|pasquale|passmore|paterson|pattison|pearsall|" +
                                "pedersen|pederson|pellerin|perryman|peterman|petersen|peterson|pettaway|pfeiffer|phillips|philpott|pichardo|" +
                                "pimental|pimentel|pinckney|pinkston|pleasant|plunkett|portillo|preciado|prentice|prescott|presnell|pressley|" +
                                "prichard|proffitt|pugliese|pumphrey)";
    namesDict.lastNames.p[9] = "(palladino|parenteau|parkhurst|parkinson|parmenter|partridge|patterson|pelletier|pemberton|pendleton|perreault|" +
                                "persinger|petterson|pettiford|pettigrew|pickering|pinkerton|pridemore|pritchard|pritchett)";
    namesDict.lastNames.q[11] = "(quintanilla)";
    namesDict.lastNames.q[4] = "(quan)";
    namesDict.lastNames.q[5] = "(quade|queen|quick|quinn|quirk)";
    namesDict.lastNames.q[6] = "(qualls|quiles|quimby|quiroz)";
    namesDict.lastNames.q[7] = "(quarles|quesada|quezada|quigley|quillen|quinlan)";
    namesDict.lastNames.q[8] = "(quinones|quinonez|quintana|quintero)";
    namesDict.lastNames.r[10] = "(rademacher|richardson|rutherford)";
    namesDict.lastNames.r[11] = "(rittenhouse|rosenberger)";
    namesDict.lastNames.r[3] = "(rae|rao|rau|ray|rea|red|rex|rey|roe|roy|rue)";
    namesDict.lastNames.r[4] = "(raab|rabe|raby|race|rael|rahn|rand|rapp|rash|rath|razo|read|real|redd|reed|reel|rees|rego|reid|reis|remy|reno|" +
                                "rhea|rice|rich|rick|rico|ries|rife|ring|rios|ritz|robb|roby|rock|rohr|rojo|roll|rome|romo|rood|roof|roop|root|" +
                                "rosa|rose|ross|roth|rowe|ruby|ruch|rudd|rudy|ruff|ruhl|ruiz|rule|rupp|rush|rusk|russ|rust|ruth|ryan)";
    namesDict.lastNames.r[5] = "(rader|ragan|rager|rains|rakes|raley|ralph|rambo|ramer|ramey|ramon|ramos|raney|range|raper|rauch|rawls|ready|reams|" +
                                "reber|reddy|reece|reedy|reese|reeve|regan|reich|reiss|reitz|revis|reyes|reyna|rhine|rhone|rhyne|ricci|ricks|rider|" +
                                "ridge|riffe|rigby|riggs|riley|rivas|rizzo|roach|roark|robey|robin|rocco|rocha|roche|rodas|roddy|roden|roger|rohde|" +
                                "rojas|rolfe|rolon|roman|romeo|roney|rooks|roper|roque|rosas|rosen|rossi|rouse|roush|rowan|royal|royce|royer|rubin|" +
                                "rubio|ruble|rueda|rumph|runge|russo|ryals|ryder)";
    namesDict.lastNames.r[6] = "(racine|radtke|rahman|railey|raines|rainey|ramage|ramsay|ramsey|randle|rangel|rankin|ransom|ranson|rascon|rausch|" +
                                "rawson|raymer|rayner|raynor|reader|reagan|reagan|reaves|reavis|rector|redden|redman|redmon|reeder|reeves|reilly|" +
                                "reimer|reinke|reiter|renaud|rendon|renfro|renner|reuter|revell|rhoads|rhoden|rhodes|richey|richie|ricker|riddle|" +
                                "ridley|riedel|rieger|riffle|rigney|rigsby|rimmer|rincon|ringer|riojas|ripley|risley|risner|ritter|rivard|rivera|" +
                                "rivero|rivers|robert|robins|robles|robson|rodman|roeder|rogers|rohrer|roland|roldan|roller|romano|romans|romero|" +
                                "romine|rooker|rooney|rosado|roscoe|rosser|rounds|roundy|rowden|rowell|rowley|roybal|rozier|rubino|rucker|ruelas|" +
                                "ruffin|rumsey|runion|runyan|runyon|rupert|russel|rutter)";
    namesDict.lastNames.r[7] = "(rackley|radford|ragland|raleigh|ralston|rameriz|ramirez|randall|randell|rankins|rathbun|ratliff|rawlins|rayborn|" +
                                "rayburn|rayford|raymond|reading|reardon|reddick|redding|redmond|rembert|renfroe|renfrow|renshaw|reynoso|rhoades|" +
                                "richard|richman|richter|rickard|rickert|rickman|riddell|riddick|rideout|ridgway|riggins|rinaldi|riordan|ritchey|" +
                                "ritchie|robbins|roberge|roberts|robison|robledo|rodarte|rodgers|roebuck|rollins|rondeau|rosales|rosario|rossman|" +
                                "rothman|roussel|rowland|rowlett|royster|rudolph|ruggles|runnels|ruppert|rushing|russell|rutland)";
    namesDict.lastNames.r[8] = "(radcliff|rafferty|ragsdale|rancourt|randazzo|randolph|rasberry|ratcliff|rathbone|rawlings|regalado|register|" +
                                "reichert|reinhart|renteria|resendez|reynolds|richards|richburg|richmond|ricketts|ridenour|ridgeway|riendeau|" +
                                "rinehart|risinger|roberson|robinett|robinson|rochelle|rockwell|roderick|rodrigez|rodrigue|rountree|rousseau|" +
                                "ruggiero|rutledge)";
    namesDict.lastNames.r[9] = "(radcliffe|rainwater|rasmussen|ratcliffe|reinhardt|remillard|remington|rhinehart|richerson|ridenhour|robertson|" +
                                "robichaud|robichaux|robinette|rochester|rodrigues|rodriguez|rodriques|rodriquez|roseberry|rosenbaum|rosenberg|" +
                                "rosenblum|rosenfeld|rosenthal|rothstein|roundtree|ruvalcaba)";
    namesDict.lastNames.s[10] = "(santamaria|scarbrough|schoonover|schumacher|schweitzer|shropshire|singletary|smitherman|somerville|southworth|" +
                                "stackhouse|stallworth|standridge|stansberry|stephenson|strickland|sturdivant|sunderland|sutherland|swearingen)";
    namesDict.lastNames.s[11] = "(satterfield|satterwhite|scarborough|schexnayder|schoonmaker|shackelford|shaughnessy|silverstein|southerland|" +
                                "summerville)";
    namesDict.lastNames.s[12] = "(stringfellow|stubblefield)";
    namesDict.lastNames.s[2] = "(su)";
    namesDict.lastNames.s[3] = "(sam|see|sim|son|suh|sun)";
    namesDict.lastNames.s[4] = "(saad|sabo|saez|sage|sain|saiz|sale|sams|sand|sapp|sass|sato|saul|seal|seay|self|sell|sena|seng|senn|shah|shaw|" +
                                "shay|shea|shin|sims|sink|sipe|sisk|slay|snow|song|sosa|soto|swan)";
    namesDict.lastNames.s[5] = "(saari|sabin|sacco|sachs|saenz|sager|salas|salem|sales|sands|sandy|santo|sauer|sauls|savoy|saxon|sayre|scalf|" +
                                "scott|seale|seals|sealy|sears|seely|segal|seger|seitz|selby|sells|serna|serra|shade|shane|shank|sharp|shedd|" +
                                "shell|shine|shinn|shipe|shipp|shirk|shook|shoop|shope|shore|short|shoup|shrum|shuck|shull|shupe|shutt|sides|" +
                                "sikes|silas|siler|sills|silva|simms|simon|sines|singh|sipes|sisco|sites|skeen|slack|slade|slate|sloan|slone|" +
                                "small|smart|smith|smock|smoot|smyth|snapp|snead|sneed|snell|snook|sokol|soler|solis|soliz|soper|soria|soucy|" +
                                "soule|sousa|south|souza|spain|spann|spear|speck|speed|speer|spell|spina|stack|stacy|stahl|stamm|stamp|stark|" +
                                "starr|staub|stcyr|steed|steel|steen|steib|stein|stepp|stern|still|stine|stith|stitt|stock|stoll|stone|storm|" +
                                "story|stott|stout|stowe|stroh|strom|stull|stump|sturm|suber|suggs|swaim|swain|swank|swann|sweat|sweet|swett|" +
                                "swift|swink|swope|sykes|szabo)";
    namesDict.lastNames.s[6] = "(sadler|sallee|salley|salmon|salter|salyer|samons|sample|samson|samuel|sander|sankey|santos|sartin|sarver|" +
                                "sasser|savage|savoie|sawyer|saxton|sayers|sayles|saylor|scales|schade|scharf|schatz|schaub|scheer|schell|" +
                                "schenk|schick|schiff|schmid|schock|schoen|scholl|scholz|schott|schram|schulz|schutt|schutz|schwab|scully|" +
                                "seaman|searcy|searle|seaton|seeger|seeley|segura|seiber|seidel|seiler|settle|setzer|seward|sewell|sexton|" +
                                "shafer|shaner|shanks|sharma|sharpe|shaver|shealy|shears|sheets|shelby|shelly|sherer|sherry|shirey|shiver|" +
                                "shores|shouse|shreve|shuler|shults|shultz|shuman|sibley|siegel|sierra|sigler|sigmon|sikora|silvas|silver|" +
                                "silvey|silvia|simmon|simone|simons|singer|sipple|sirois|sisson|skaggs|skiles|slagle|slater|slaton|slavin|" +
                                "sledge|slocum|smalls|smiley|smythe|snider|snipes|snyder|soares|solano|somers|sommer|sotelo|sowder|sowell|" +
                                "sowers|sparks|speaks|spears|spence|sperry|spicer|spiker|spikes|spinks|spires|spivey|spring|squire|stacey|" +
                                "staggs|staley|stamey|stamps|starks|staten|staton|steele|steger|stella|steven|stiles|stites|stjohn|stocks|" +
                                "stoker|stokes|stoltz|stoner|stonge|stoops|storer|storey|storms|stotts|stover|strain|strait|strand|straub|" +
                                "strawn|street|strode|strong|stroud|stroup|struck|strunk|stuart|stubbs|studer|stultz|stumpf|styles|suarez|" +
                                "suiter|summer|sumner|surber|sutter|suttle|sutton|suzuki|swarey|swartz|sweatt|swiger|sylvia)";
    namesDict.lastNames.s[7] = "(sackett|saddler|safford|salazar|salcedo|salcido|saldana|salerno|salgado|salinas|salmons|salyers|sammons|" +
                                "samples|sampson|samuels|sanborn|sanches|sanchez|sanders|sandler|sandlin|sanford|sansone|santana|santoro|" +
                                "santoyo|sargent|sattler|sauceda|saucedo|saucier|saville|sawyers|scalise|scanlan|scanlon|schafer|schenck|" +
                                "scherer|schmidt|schmitt|schmitz|schnell|schramm|schrock|schuler|schulte|schultz|schulze|schuman|schwarz|" +
                                "scruggs|scudder|seabolt|searles|sedillo|segovia|seibert|seifert|sellars|sellers|seltzer|serrano|serrato|" +
                                "session|sessoms|settles|sevilla|seymore|seymour|shaffer|shankle|shannon|shapiro|sharkey|shearer|sheehan|" +
                                "sheldon|shelley|shelton|shepard|sherman|sherrod|sherwin|shields|shipley|shipman|shirley|shively|shivers|" +
                                "shockey|shorter|showers|shrader|shriver|shubert|shumate|shumway|shuster|siebert|sievers|silvers|simmons|" +
                                "simonds|simpson|singley|skelton|skinner|skipper|slayton|slusher|smalley|snowden|soileau|solberg|solomon|" +
                                "solorio|sommers|sonnier|soriano|sorrell|sparrow|speight|spencer|spiegel|spiller|spinner|spitzer|spooner|" +
                                "sprague|spriggs|springs|sprouse|spruill|squires|stadler|stamper|stancil|stanley|stanton|staples|starkey|" +
                                "starnes|stclair|stearns|steffen|stegall|steiner|steinke|stephan|stephen|sterner|stevens|steward|stewart|" +
                                "stidham|stinson|stlouis|stocker|stovall|stowell|stowers|strader|strahan|strange|strauss|strobel|stroman|" +
                                "struble|stuckey|sturgis|sublett|sudduth|sullins|summers|sumpter|sumrall|surface|surratt|sussman|sutphin|" +
                                "suttles|swanson|sweeney|swenson|swindle|swinney|swinton|swisher|switzer)";
    namesDict.lastNames.s[8] = "(saavedra|sadowski|saldivar|salvador|sanabria|sandberg|sandifer|sandoval|santiago|saunders|scarlett|schaefer|" +
                                "schaffer|schaller|schiller|schlegel|schrader|schroder|schubert|schulman|schumann|schuster|schwartz|scofield|" +
                                "scoggins|scribner|sessions|severson|shanahan|shanklin|shattuck|shephard|shepherd|sheppard|sheridan|sherlock|" +
                                "sherrill|sherwood|shilling|shockley|shoemake|shoffner|shotwell|shumaker|silveira|simonson|simpkins|sinclair|" +
                                "sisneros|sizemore|skidmore|slattery|smithers|smithson|smothers|sorensen|sorenson|sorrells|southard|southern|" +
                                "spalding|spangler|sparkman|spearman|spellman|sperling|spillman|spinelli|spradlin|springer|sprinkle|spurgeon|" +
                                "spurlock|stafford|stallard|standley|stanfill|stanford|starling|stauffer|steadman|stebbins|steelman|steffens|" +
                                "stephens|sterling|stickney|stiffler|stillman|stiltner|stilwell|stinnett|stockman|stockton|stoddard|stouffer|" +
                                "stpierre|straight|stratton|strawser|streeter|stringer|strother|sturgeon|sturgill|stutzman|sullivan|sundberg|" +
                                "swafford|sweitzer|swindell)";
    namesDict.lastNames.s[9] = "(salisbury|salvatore|samaniego|samuelson|sanderson|sandstrom|santacruz|santillan|sarmiento|scarberry|schaeffer|" +
                                "schaffner|scheffler|schilling|schindler|schlosser|schlueter|schneider|schofield|schreiber|schreiner|schroeder|" +
                                "scroggins|sebastian|sepulveda|severance|sheffield|shifflett|shoemaker|shoulders|showalter|sifuentes|silverman|" +
                                "singleton|slaughter|smallwood|snodgrass|solorzano|spaulding|stallings|stalnaker|standifer|stanfield|stansbury|" +
                                "stapleton|steinberg|steinmetz|sternberg|stevenson|stgermain|sthilaire|stillwell|stockdale|stockwell|stollings|" +
                                "stoltzfus|stribling|strickler|stricklin|stromberg|summerlin|sylvester|szymanski)";
    namesDict.lastNames.t[10] = "(tankersley|thibodeaux|timberlake|trowbridge)";
    namesDict.lastNames.t[2] = "(to)";
    namesDict.lastNames.t[3] = "(tam|tan|tew|tom|toy|tse|tso|tye)";
    namesDict.lastNames.t[4] = "(tabb|taft|tait|tang|tapp|tarr|tate|teal|teel|thai|thao|thom|tice|till|timm|todd|toms|tong|toon|toro|toth|towe|" +
                                "tran|troy|tsai|tuck|tull|turk)";
    namesDict.lastNames.t[5] = "(taber|tabor|tamez|tapia|tatro|tatum|tello|terry|tesch|testa|tharp|theis|thiel|thies|thoma|thorn|thorp|tibbs|" +
                                "tighe|timms|titus|tobey|tobin|toler|tolle|tomas|toner|toney|toole|tovar|tower|towle|towne|towns|tracy|trapp|" +
                                "trask|treat|trejo|trent|trice|trigg|trinh|tripp|trott|trout|truax|trull|tsang|tubbs|tucci|tudor|tully|twigg|" +
                                "tyler|tyner|tynes|tyree|tyson)";
    namesDict.lastNames.t[6] = "(tafoya|talbot|talley|tamayo|tanaka|tanner|tapley|tarter|tarver|taylor|teague|tedder|teeter|tejada|tejeda|telles|" +
                                "tellez|temple|tenney|thames|tharpe|thayer|thomas|thorne|thorpe|thrash|tiller|tilley|tillis|tilton|tingle|tinker|" +
                                "tinney|tipton|tirado|tobias|toledo|tolley|tolman|tolson|tomlin|tooley|toombs|toomey|torres|torrey|torrez|totten|" +
                                "towers|towner|townes|tracey|trader|trahan|travis|treece|troupe|troyer|truitt|truman|truong|tsosie|tucker|tuggle|" +
                                "tullis|turley|turman|turner|turney|turpin|tuttle|twitty|twomey)";
    namesDict.lastNames.t[7] = "(tackett|taggart|talbert|talbott|tallent|tallman|tarango|tardiff|tarrant|tavares|tavarez|taveras|teasley|tedesco|" +
                                "tedford|tennant|tenorio|terrell|terrill|tessier|thacker|thaxton|theisen|theriot|thielen|thigpen|thomsen|thomson|" +
                                "thorson|thorton|thrower|thurber|thurman|tidwell|tierney|tiffany|tillery|tillman|timmons|tincher|tindall|tinsley|" +
                                "tisdale|tolbert|toliver|toscano|townley|trainor|travers|traylor|trevino|tribble|trimble|trotman|trotter|trudeau|" +
                                "tunnell|turgeon|turnage|turnbow|tyndall|tyrrell)";
    namesDict.lastNames.t[8] = "(teixeira|tennyson|terrazas|thatcher|therrien|thibault|thomason|thompson|thornton|thrasher|thurmond|thurston|" +
                                "tibbetts|tijerina|tolliver|tompkins|torrence|townsend|trammell|trantham|treadway|tremblay|trinidad|triplett|" +
                                "trombley|troutman|trujillo|trussell|tunstall|turcotte|turnbull)";
    namesDict.lastNames.t[9] = "(takahashi|templeton|tetreault|theriault|thibeault|thibodeau|thompkins|thornburg|thornhill|tillotson|timmerman|" +
                                "tolentino|tomlinson|torgerson|toussaint|treadwell|truesdale)";
    namesDict.lastNames.u[3] = "(uhl)";
    namesDict.lastNames.u[5] = "(ulloa|ulmer|unger|unruh|upton|urban|urena|urias|uribe|usher|utley|utter)";
    namesDict.lastNames.u[6] = "(ulrich|upshaw|urbina|ussery)";
    namesDict.lastNames.u[8] = "(ulibarri|upchurch|urquhart)";
    namesDict.lastNames.u[9] = "(underhill|underwood)";
    namesDict.lastNames.v[10] = "(valenzuela|valladares|vanbuskirk|vandenberg|vanderpool|vermillion|villagomez|villalobos|villanueva|villarreal|" +
                                "villasenor)";
    namesDict.lastNames.v[11] = "(villalpando)";
    namesDict.lastNames.v[12] = "(vaillancourt)";
    namesDict.lastNames.v[13] = "(vanlandingham)";
    namesDict.lastNames.v[2] = "(vo|vu)";
    namesDict.lastNames.v[3] = "(van|via|vue)";
    namesDict.lastNames.v[4] = "(vaca|vail|vang|vann|veal|vega|vela|vera|vest|vice|vick|vogt|volk|volz|voss)";
    namesDict.lastNames.v[5] = "(vaden|valle|vance|varga|vargo|veach|velez|veliz|vidal|viera|vigil|villa|vines|viola|vogel|voigt|volpe|vuong)";
    namesDict.lastNames.v[6] = "(vinson|valles|vaughn|valley|varner|varney|vetter|verret|vitale|vachon|vereen|valdes|vernon|vierra|vaught|valdez|" +
                                "vargas|verdin|victor|varela|vestal|virgil|vannoy|vining|voyles|vieira)";
    namesDict.lastNames.v[7] = "(vaccaro|valadez|valente|valenti|valerio|vallejo|vandyke|vanegas|vanhorn|vanover|vanpelt|vanzant|vasquez|vaughan|" +
                                "vazquez|velarde|velasco|venable|venegas|ventura|verdugo|vergara|vickers|vickery|vidrine|vincent|vollmer)";
    namesDict.lastNames.v[8] = "(valdivia|valencia|valentin|valliere|valverde|vanburen|vandiver|vandusen|vanhoose|vanmeter|veilleux|verduzco|" +
                                "victoria|villegas|vineyard|violette|voorhees)";
    namesDict.lastNames.v[9] = "(valentine|valentino|vanhouten|vansickle|vanwinkle|velasquez|velazquez|villareal)";
    namesDict.lastNames.w[10] = "(wisniewski|wainwright|wooldridge|winchester|williamson|willoughby|washington|waterhouse|weathersby|whitehouse|" +
                                "whittemore|willingham|westbrooks|wellington|whitehurst|warrington)";
    namesDict.lastNames.w[11] = "(weatherford|whittington|witherspoon|worthington)";
    namesDict.lastNames.w[12] = "(weatherspoon|westmoreland)";
    namesDict.lastNames.w[2] = "(wu)";
    namesDict.lastNames.w[3] = "(way|woo)";
    namesDict.lastNames.w[4] = "(wade|wahl|walk|wall|walz|wang|ward|ware|watt|webb|weed|weil|weir|weis|wert|west|wick|wild|will|wilt|wine|wing|" +
                                "winn|wise|witt|wold|wolf|wong|wood|word|wray|wren|wynn)";
    namesDict.lastNames.w[5] = "(wages|waite|waits|waldo|wales|walls|walsh|waltz|watts|waugh|wayne|weber|weeks|weems|weese|weise|weiss|welch|wells|" +
                                "welsh|welty|wendt|wentz|werth|wertz|wheat|white|whitt|whyte|wicks|wiese|wiggs|wight|wilde|wiles|wiley|wilke|wilks|" +
                                "wills|wingo|wirth|witte|wolfe|wolff|woods|woody|woolf|worth|wrenn|wyant|wyatt|wyche|wylie|wyman|wynne)";
    namesDict.lastNames.w[6] = "(wessel|wilkie|waller|wesley|wacker|werner|wilder|wilber|webber|womble|wexler|wilcox|wayman|wicker|winder|wiener|" +
                                "weller|womack|wisner|wester|wetzel|whalen|winton|wallis|weston|willis|wojcik|wesson|whited|wadley|whelan|wright|" +
                                "wilson|walton|winter|walker|wallin|waites|weiler|warren|worthy|walter|witham|warden|wooden|warner|wooley|winner|" +
                                "winger|weldon|walden|weaver|willie|wilkes|waddle|wallen|wimmer|walley|wasson|wisdom|wagner|wyrick|wenzel|weimer|" +
                                "weiner|welton|weddle|willey|wegner|weigel|wendel|wilbur|wenger|waring|weiser|welker|wilmot|whaley|worley|worden|" +
                                "wooten|witter|waters|watson|waldon)";
    namesDict.lastNames.w[7] = "(wilhite|wilmoth|winston|william|willett|wallace|willard|wiggins|wigfall|witcher|wortham|wilhelm|willson|wilburn|" +
                                "windsor|wheeler|windham|winters|wilcher|wilborn|wolcott|wingard|wittman|withrow|wilkins|winslow|watters|waldman|" +
                                "wagoner|wilkens|waldrop|wyckoff|worrell|weisman|waddell|wachter|wingate|warwick|webster|worsham|warnock|walston|" +
                                "watkins|warrick|walters|wolford|watford|walther|whitley|wysocki|worthen|welborn|wofford|woolley|wozniak|winkler|" +
                                "woodson|withers|weekley|wildman|walling|wetmore|whitted|wilfong|whitman|woodall|winfrey|whiting|whipple|wheaton|" +
                                "whatley|woodley|woodman|wieland|whittle|whitten|wiegand|wickham|whorton|whitmer|whitson|waldron|weiland|woodard|" +
                                "wellman|woolery|wortman|whitlow|weidner|wampler|woosley|woolard|woolsey|wharton|whitney|wescott|wiseman|workman)";
    namesDict.lastNames.w[8] = "(waggoner|warfield|washburn|watanabe|waterman|weathers|weinberg|westcott|westfall|westover|westphal|wheatley|" +
                                "whitacre|whitaker|whitcomb|whiteley|whiteman|whitener|whitford|whitlock|whitmire|whitmore|wilbanks|willette|" +
                                "williams|wimberly|winchell|winfield|winstead|woodbury|woodcock|woodford|woodland|woodring|woodruff|woodward)";
    namesDict.lastNames.w[9] = "(wadsworth|wakefield|wasserman|watterson|weatherby|weatherly|weinstein|weintraub|wentworth|westbrook|westerman|" +
                                "whetstone|whisenant|whitehead|whiteside|whitfield|whittaker|whitworth|wilkerson|wilkinson|williford|wingfield|" +
                                "witkowski|woodhouse|woodworth)";
    namesDict.lastNames.x[5] = "(xiong)";
    namesDict.lastNames.y[10] = "(youngblood|yarborough)";
    namesDict.lastNames.y[2] = "(yi|yu)";
    namesDict.lastNames.y[3] = "(yan|yee|yon|yoo)";
    namesDict.lastNames.y[4] = "(yang|yoho|yoon|york|yost|yuen)";
    namesDict.lastNames.y[5] = "(yager|yancy|yanez|yates|yocum|yoder|young|yount)";
    namesDict.lastNames.y[6] = "(yamada|yancey|yazzie|ybarra|yeager|youngs)";
    namesDict.lastNames.y[7] = "(yoshida|youmans|younger)";
    namesDict.lastNames.y[8] = "(yingling|yamamoto|youngman)";
    namesDict.lastNames.y[9] = "(yarbrough)";
    namesDict.lastNames.z[10] = "(zimmermann)";
    namesDict.lastNames.z[4] = "(zack|zahn|zink|zinn|zito|zook|zorn)";
    namesDict.lastNames.z[5] = "(zayas|zhang|zuber)";
    namesDict.lastNames.z[6] = "(zamora|zander|zapata|zarate|zavala|zelaya|zeller|zepeda|zimmer|zuniga)";
    namesDict.lastNames.z[7] = "(zachary|zamudio|zeigler|ziegler)";
    namesDict.lastNames.z[8] = "(zambrano|zaragoza)";
    namesDict.lastNames.z[9] = "(zielinski|zimmerman)";
    placeList = "(afghanistan|abu\\sdhabi|abuja|accra|adamstown|addis\\sababa|åland\\sislands|albania|albany|algeria|algiers|alofi|" +
             "american\\ssamoa|amman|amsterdam|anchorage|andorra|andorra\\sla\\svella|angola|anguilla|ankara|annapolis|" +
             "antananarivo|antarctica|antigua\\sand\\sbarbuda|apia|argentina|armenia|aruba|ashgabat|asmara|astana|" +
             "asunción|athens|atlanta|augusta|austin|australia|austria|avarua|azerbaijan|baghdad|bahamas|bahrain|baku|" +
             "bamako|bandar\\sseri\\sbegawan|bangkok|bangladesh|bangui|banjul|barbados|basseterre|baton\\srouge|beijing|" +
             "beirut|belarus|belgium|belgrade|belize|belmopan|benin|berlin|bermuda|bern|bhutan|billings|birmingham|" +
             "bishkek|bismarck|bissau|bogotá|boise|bolivia|bosnia\\sand\\sherzegovina|boston|botswana|bouvet\\sisland|brasília|" +
             "bratislava|brazil|brazzaville|bridgeport|bridgetown|british\\sindian\\socean\\sterritory|brunei\\sdarussalam|" +
             "brussels|bucharest|budapest|buenos\\saires|bujumbura|bulgaria|burkina\\sfaso|burundi|cairo|cambodia|" +
             "cameroon|canada|canberra|cape\\sverde|caracas|carson\\scity|castries|cayman\\sislands|central\\safrican\\srepublic|" +
             "chad|charleston|charlotte|charlotte\\samalie|charlotte\\samalie|cheyenne|chicago|chile|china|chisinau|" +
             "christmas\\sisland|cincinnati|cleveland|cockburn\\stown|cocos\\s(keeling)\\sislands|colombia|columbia|columbus|" +
             "comoros|conakry|concord|congo|cook\\sislands|copenhagen|costa\\srica|côte\\sd'ivoire|croatia|cuba|cyprus|" +
             "czech\\srepublic|czechoslovakia|dakar|damascus|denmark|denver|des\\smoines|dhaka|dili|djibouti|djibouti|" +
             "dodoma|doha|dominica|dominican\\srepublic|douglas|dover|dublin|dushanbe|east\\stimor|ecuador|egypt|" +
             "el\\ssalvador|episkopi\\scantonment|equatorial\\sguinea|eritrea|estonia|ethiopia|fagatogo|falkland\\sislands\\s(malvinas)|" +
             "fargo|faroe\\sislands|fiji|finland|france|frankfort|freetown|french\\sguiana|french\\spolynesia|funafuti|" +
             "gabon|gaborone|gambia|george\\stown|georgetown|georgia|germany|ghana|gibraltar|gibraltar|greece|greenland|" +
             "grenada|grytviken|guadeloupe|guam|guatemala|guatemala\\scity|guernsey|guinea|guinea-bissau|gustavia|guyana|" +
             "hagåtña|hagåtña|haiti|hamilton|hanoi|harare|hargeisa|harrisburg|hartford|havana|harvard|yale|johns hopkins|" +
             "heard\\sisland\\sand\\smcdonald\\sislands|helena|helsinki|holy\\ssee|honduras|hong\\skong|honiara|honolulu|houston|" +
             "hungary|iceland|india|indianapolis|indonesia|iran|iraq|ireland|islamabad|isle\\sof\\sman|israel|italy|jackson|" +
             "jacksonville|jakarta|jamaica|jamestown|japan|jefferson\\scity|jersey|jerusalem|jordan|juneau|kabul|kampala|" +
             "kansas\\scity|kathmandu|kazakhstan|kenya|khartoum|kiev\\s(kyiv)|kigali|kingston|kingstown|kinshasa|" +
             "kiribati|korea|kuala\\slumpur|kuwait|kuwait\\scity|kyrgyzstan|la\\spaz|laâyoune\\s(el\\saaiún)|lansing|laos|" +
             "las\\svegas|latvia|lebanon|lesotho|liberia|libreville|libyan\\sarab\\sjamahiriya|liechtenstein|lilongwe|lima|" +
             "lincoln|lisbon|lithuania|little\\srock|ljubljana|lomé|london|los\\sangeles|louisville|luanda|lusaka|luxembourg|" +
             "luxembourg\\scity|macao|macedonia|madagascar|madison|madrid|majuro|malabo|malawi|malaysia|maldives|malé|mali|malta|" +
             "mamoudzou|managua|manama|manchester|manila|maputo|marigot|marshall\\sislands|martinique|maseru|mata-utu|" +
             "mauritania|mauritius|mayotte|mbabane|melekeok|memphis|mexico|mexico\\scity\\s\\se|micronesia|milwaukee|minneapolis|" +
             "minsk|mogadishu|moldova|monaco|monaco|mongolia|monrovia|montenegro|montevideo|montgomery|montpelier|montserrat|" +
             "morocco|moroni|moscow|mozambique|muscat|myanmar|n'djamena|nairobi|namibia|nashville|nassau|nauru|naypyidaw|" +
             "nepal|netherlands|netherlands\\santilles|new\\scaledonia|new\\sdelhi|new\\sorleans|new\\syork\\scity|new\\szealand|newark|niamey|" +
             "nicaragua|nicosia|niger|nigeria|niue|norfolk\\sisland|north\\skorea|northern\\smariana\\sislands|norway|nouakchott|nouméa|" +
             "nukuʻalofa|nuuk|oklahoma\\scity|olympia|omaha|oman|oranjestad|oslo|ottawa|ouagadougou|p'yŏngyang|pago\\spago|" +
             "pago\\spago|pakistan|palau|palestine|palestinian\\sterritory|palikir|panama|panama\\scity|papeete|papua\\snew\\sguinea|" +
             "paraguay|paramaribo|paris|peru|philadelphia|philippines|phnom\\spenh|phoenix|pierre|pitcairn|plymouth\\sf|podgorica|" +
             "poland|port\\slouis|port\\smoresby|port\\sof\\sspain|port\\svila|port-au-prince|portland|porto-novo|portugal|prague|" +
             "praia|pretoria|priština|providence|puerto\\srico|putrajaya|qatar|quito|rabat|raleigh|ramallah|reunion|reykjavík|" +
             "richmond|riga|riyadh|road\\stown|romania|rome|roseau|russian\\sfederation|rwanda|sacramento|saint\\sbarthélemy|" +
             "saint\\shelena|saint\\skitts\\sand\\snevis|saint\\slucia|saint\\smartin|saint\\spaul|saint\\spierre\\sand\\smiquelon|saint\\svincent|" +
             "grenadines|saint-martin|saipan|saipan|salem|salt\\slake\\scity|samoa|san\\sfrancisco|san\\sjosé|san\\sjuan|san\\sjuan|" +
             "san\\smarino|san\\smarino|san\\ssalvador|sanaá|santa\\sfe|santiago|santo\\sdomingo|são\\stomé|sao\\stome\\sand\\sprincipe|" +
             "sarajevo|saudi\\sarabia|seattle|senegal|seoul|serbia|seychelles|sierra\\sleone|singapore|singapore|sioux\\sfalls|skopje|" +
             "slovakia|slovenia|sofia|solomon\\sislands|somalia|south\\safrica|south\\sgeorgia\\sand\\sthe\\ssouth\\ssandwich\\sislands|south\\skorea|" +
             "south\\starawa|spain|springfield|sri\\sjayawardenepura|sri\\slanka|st.\\sgeorge's|st.\\shelier|st.\\sjohn's|st.\\slouis|" +
             "st.\\speter\\sport|st.\\spierre|stanley|stockholm|sucre|sudan|sukhum|suriname|suva|svalbard\\sand\\sjan\\smayen|" +
             "swaziland|sweden|switzerland|syrian\\sarab\\srepublic|taipei|taiwan|tajikistan|tallahassee|tallinn|tanzania|tashkent|" +
             "tbilisi|tegucigalpa|tehran|thailand|the\\ssettlement|thimphu|tibet|timor-leste|tirana|tiraspol|togo|tokelau|" +
             "tokyo|tonga|topeka|tórshavn|trenton|trinidad\\sand\\stobago|tripoli|tskhinval|tunis|tunisia|turkey|turkmenistan|" +
             "turks\\sand\\scaicos\\sislands|tuvalu|uganda|ukraine|ulaanbaatar|united\\sarab\\semirates|united\\skingdom|united\\sstates|" +
             "uruguay|uzbekistan|vaduz|valletta|vanuatu|vatican\\scity|vatican\\scity|venezuela|victoria|vienna|vientiane|" +
             "vietnam|vilnius|virgin\\sislands|virginia\\sbeach|wallis\\sand\\sfutuna|warsaw|washington|wellington|western\\ssahara|" +
             "wichita|willemstad|wilmington|windhoek|yamoussoukro|yaoundé|yaren|yemen|yerevan|yugoslavia|zagreb|zaire|" +
             "zambia|zimbabwe)";
