/*
【全体構成】
	cont
		timeLineTable
			timeLineTableIn
				timeLineCategory
					ul
						li カテゴリ名
				time5
					timeTitle 時間
					category
						ul
							li 番組
							li 番組
								…
					category
						ul
							li 番組
								…
					…
				time6
				…
*/
//部品類----------------------------------
//Element作成の部品
function createElement(tag, name, id, c) {
	name = document.createElement(tag);
	if(id != ""){
		name.id = id;
	}
	if(c != ""){
		name.className = c;
	}
	return name;
};

//番組取得を実行する処理
function Getgon(day){
	var url;
	var days = $('#selectdate').val();
	if(!day == ""){
		days = day;
	}
	if (days == ""){
		days = dateToStr12HPad0(new Date);
	}
	url = '/top?days=' + days
	gon.watch('program',{ interval: null, method: "get" , url: url}, getProgram );
};

//プログラムを取得する
function getProgram(program){
	//取得した番組をJSONにする
	program = JSON.parse(program)
	//取得した番組の開始時間でソートをさせる
	/*
	program.sort(function(atime,btime) {
		Atime = atime.start_time_u;
		Btime = btime.start_time_u;
		return Atime > Btime ? 1 : -1;
	});
	*/

	//timelineBoxを初期化して、再定義する-------
	//contがroot
	var parent = document.getElementById("cont");
	if(document.getElementsByClassName("timeLineTable").length == 0){
		//初期状態の時は作成する
		var timeLineTable = createElement("div", timeLineTable, "", "timeLineTable");
		parent.appendChild(timeLineTable);
	}else{
		//既存にある場合は、一度削除してから再度作成を行う
		//timeLineTableを取得
		timeLineTable = document.getElementsByClassName("timeLineTable");
		//timeLineTableのclass全てを削除する
		for (var i=0; i<timeLineTable.length; i++) {
		 timeLineTable[i] = ""
		 parent.removeChild(timeLineTable[i]);
		}
		//timeLineTableを再度作成する
		timeLineTable = createElement("div", timeLineTable, "", "timeLineTable");
		parent.appendChild(timeLineTable);
	}

	//親構築開始------------------------
	var timeLineTableIn = createElement("div", timeLineTableIn, "timeLineTableIn", "timeLineTableIn");
	var timeLineCategory = createElement("div", timeLineCategory, "timeLineCategory", "timeLineCategory");
	parent.appendChild(timeLineTable);
	timeLineTable.appendChild(timeLineTableIn);
	timeLineTableIn.appendChild(timeLineCategory);
	//親構築終了------------------------

	//ジャンルリスト作成
	var genre_ul = createElement("ul", genre_ul, "", "");
	timeLineCategory.appendChild(genre_ul);
	var g_id = 0;
	for(var g in genreList){
		var genre_li = createElement("li", genre_ul, "", "");
		genre_ul.appendChild(genre_li)
		genre_li.textContent = genreList[g][1];
	}
	//ジャンル名構築終了------------------------
	//p: programのindex
	//i: 時間のindex
	//g: genre
	var hantei_day;
	for(i = 5; i <= 28; i++){
		time_int = i
		//24以上の場合は24を差し引く
		if(i >= 24){
			time_int = i - 24
		}
		//<div id="time5" class="time5">
		//この形にする
		var timeString = "timeBox time" + time_int
		var time = createElement("div", time, timeString, timeString);
		timeLineTableIn.appendChild(time);
		//timeTitleは時間の値を入れる
		var timeTitle = createElement("div", timeTitle, "", "timeTitle");
		time.appendChild(timeTitle);
		timeTitle.textContent = time_int
		//ジャンルの数だけ
		for(var g in genreList){
			var category = createElement("div", category, "category", "category");
			time.appendChild(category);
			var program_ul = createElement("ul", program_ul, "", "");
			category.appendChild(program_ul);
			//jsonを展開する形にする
			for(p in program){
				//開始時間の時間部分だけ切り出し
				var start_time_h = unixtimechange_h(program[p].start_time_u)
				hantei_day = program[p].day
				var program_gen = program[p].genre
					/*
					【番組構成】
					timeLineDate
						startTime typeYes(No):スタート時間
						（typeはYesでアーカイブ有、Noでアーカイブ無）
					timeLineSumb
						a:番組へのリンク
							img:サムネイル
					username
						img:チャンネルアイコン
						p:チャンネル名
					timeLineInfo
						timeLineCat:カテゴリ名
						yokiCount:よき！
							a:良きボタン押下時トリガー
								img:良きアイコン
					a:番組へのリンク
						timeLineDatail:番組タイトル
					timeLineTag:番組タグ
					*/
					if (time_int == start_time_h && genreList[g][0] == program_gen){
						//番組読み込み
						var program_li = createElement("li", program_li, "", "");
						program_ul.appendChild(program_li);
						//timeLineDate---------------------------------------------------------------------------------
						var timeLineDate = createElement("div", timeLineDate, "timeLineDate", "timeLineDate");
						//アーカイブの判定
						if(program[p].archives == "true"){
							var startTime = createElement("p", startTime, "startTime", "startTime typeYes");
						}else{
							var startTime = createElement("p", startTime, "startTime", "startTime");
						};
						startTime.textContent = unixtimechange(program[p].start_time_u);
						timeLineDate.appendChild(startTime);
						//timeLineSumb---------------------------------------------------------------------------------
						var timeLineSumb = createElement("div", timeLineSumb, "timeLineSumb", "timeLineSumb");
						var timeLineSumb_a = createElement("a", timeLineSumb_a, "", "");
						var timeLineSumb_img = createElement("img", timeLineSumb_a, "", "");
						//サムネイルが存在しない時には画像を表示しない
						if(program[p].image.url != null){
							timeLineSumb_a.href = "/program/detail/" + program[p].id;
							timeLineSumb_img.src = program[p].image.url
							timeLineSumb.appendChild(timeLineSumb_a);
							timeLineSumb_a.appendChild(timeLineSumb_img);
						}
						//userName-------------------------------------------------------------------------------------
						var userName = createElement("div", userName, "userName", "userName");
						var channel_img = createElement("img", channel_img, "", "");
						var channel_name = createElement("p", channel_name, "", "");
						userName.appendChild(channel_img);
						userName.appendChild(channel_name);
						channel_img.src = program[p].c_icon;
						channel_name.textContent = program[p].c_name;
						//timeLineInfo---------------------------------------------------------------------------------
						var timeLineInfo = createElement("div", timeLineInfo, "timeLineInfo", "timeLineInfo");
						var timeLineCat = createElement("div", timeLineCat, "timeLineCat", "timeLineCat");
						var yokiCount = createElement("div", yokiCount, "yokiCount", "yokiCount");
						var yokiCount_a = createElement("a", yokiCount_a, "", "");
						var yokiCount_img = createElement("img", yokiCount_img, "Yokiimg" + program[p].id, "");
						var yokiCount_span = createElement("span", yokiCount_span, "YokiSpan" + program[p].id, "");
						timeLineInfo.appendChild(timeLineCat);
						timeLineInfo.appendChild(yokiCount);
						yokiCount.appendChild(yokiCount_a);
						yokiCount.appendChild(yokiCount_span);
						yokiCount_a.appendChild(yokiCount_img);
						yokiLink = "/program/" + program[p].id + "/like?callback=top"
						yokiCount_a.href = "javascript:void(0);"
						yokiClick = "OnLinkClick(" + program[p].id + ");"
						yokiCount_a.setAttribute("onclick", yokiClick)
						if(program[p].yoki){
							yokiCount_img.src = "/img/yokiOn.png";
						}else{
							yokiCount_img.src = "/img/yoki.png";
						}
						timeLineCat.textContent = genreList[g][1];
						yokiCount_span.textContent = program[p].like;
						//a（番組タイトル）-----------------------------------------------------------------------------
						var p_title_a = createElement("a", p_title_a, "", "");
						var timeLineDetail = createElement("div", timeLineDetail, "timeLineDatail", "timeLineDatail");
						p_title_a.appendChild(timeLineDetail)
						p_title_a.href = "/program/detail/" + program[p].id;
						timeLineDetail.textContent = program[p].p_title
						//timeLineTag（タグ）---------------------------------------------------------------------------
						var timeLineTag = createElement("div", timeLineTag, "timeLineTag", "timeLineTag");
						timeLineTag.textContent = program[p].tag
						//program_liのセットアップ----------------------------------------------------------------------
						program_li.appendChild(timeLineDate);
						program_li.appendChild(timeLineSumb);
						program_li.appendChild(userName);
						program_li.appendChild(timeLineInfo);
						program_li.appendChild(p_title_a);
						program_li.appendChild(timeLineTag);
				}
			}
		}
	}
	scrollnow()
}

//画面が全て読み込まれた後の処理
window.onload = function() {
	document.getElementById('selectdate').onchange();
};

//unixtimeから時間と分を変換する
function unixtimechange(intUnit){
	var ts = intUnit;
	var d = new Date( ts * 1000 );
	var year  = d.getFullYear();
	var month = d.getMonth() + 1;
	var day  = d.getDate();
	var hour = ( d.getHours()   < 10 ) ? '0' + d.getHours()   : d.getHours();
	var min  = ( d.getMinutes() < 10 ) ? '0' + d.getMinutes() : d.getMinutes();
	var sec   = ( d.getSeconds() < 10 ) ? '0' + d.getSeconds() : d.getSeconds();
	return hour + ':' + min;
}

//unixtimeから時間だけを変換する
function unixtimechange_h(intUnit){
	var ts = intUnit;
	var d = new Date( ts * 1000 );
	var year  = d.getFullYear();
	var month = d.getMonth() + 1;
	var day  = d.getDate();
	var hour = ( d.getHours()   < 10 ) ? '0' + d.getHours()   : d.getHours();
	var min  = ( d.getMinutes() < 10 ) ? '0' + d.getMinutes() : d.getMinutes();
	var sec   = ( d.getSeconds() < 10 ) ? '0' + d.getSeconds() : d.getSeconds();
	return hour ;
}

//日付の表記方法を変える
function dateToStr12HPad0(date) {
		var format = 'YYYY-MM-DD'
		var hours = date.getHours();
		var ampm = hours < 12 ? 'AM' : 'PM';
		hours = hours % 12;
		hours = (hours != 0) ? hours : 12; // 0時は12時と表示する
		format = format.replace(/YYYY/g, date.getFullYear());
		format = format.replace(/MM/g, ('0' + (date.getMonth() + 1)).slice(-2));
		format = format.replace(/DD/g, ('0' + date.getDate()).slice(-2));
		format = format.replace(/hh/g, ('0' + hours).slice(-2));
		format = format.replace(/mm/g, ('0' + date.getMinutes()).slice(-2));
		format = format.replace(/ss/g, ('0' + date.getSeconds()).slice(-2));
		format = format.replace(/AP/, ampm);
		return format;
};

//良きボタンを押下時に起動。番組idが引数。
function OnLinkClick(id) {
		yokiLink = "/program/" + id + "/like_ajax"
        $.ajax({
            url: yokiLink,
            type: "GET",
            dataType: "html",
            success: function(data) {
            	img_id = "Yokiimg" + id
            	span_id = "YokiSpan" + id
                img = document.getElementById(img_id);
                span = document.getElementById(span_id);
                img.src = "/img/yokiOn.png";
                data = JSON.parse(data)
                span.textContent = data["like"]
            },
            error: function(data) {
                alert("errror");
            }
        });
};

//現在時刻までスクロールをする処理
function scrollnow(){
	var now = new Date();
	var headerHight = 190; //ヘッダの高さ
    var idname = '.time' + now.getHours() //現在時刻を判定して、classを取得
    var position = $(idname).offset().top - headerHight //取得した位置からヘッダ分を差し引く
    $("html, body").animate({scrollTop:position}, 550, "swing"); //差し引いた値の位置までスクロールする
}