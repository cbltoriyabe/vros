//番組変数初期化
var days;
var timelineBox;
var timeLineSumb = createElement("div", timeLineSumb, "timeLineSumb", "timeLineSumb");
var timeLineDate = createElement("div", timeLineDate, "timeLineDate", "timeLineDate");
var program_u = createElement("ul", program_u, "program", "program");
var program_l = createElement("li", program_l, "program", "program");
var username = createElement("div", username, "username", "username");
var timeLineDatail = createElement("div", timeLineDatail, "timeLineDatail", "timeLineDatail");
var timeLineTag = createElement("div", timeLineTag, "timeLineTag", "timeLineTag");
var startTime = createElement("p", startTime, "startTime", "startTime");
var yokiCount = createElement("p", yokiCount, "yokiCount", "yokiCount");
var c_name = createElement("p", c_name, "c_name", "c_name");
var c_icon = createElement("img", c_icon, "c_icon", "c_icon");
var programName = createElement("p", programName, "programName", "programName");
var thumbnail = createElement("img", thumbnail, "thumbnail", "thumbnail");
var count = 0;

window.onload = function() {
	document.getElementById('selectdate').onchange();
};

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
}

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

//. 比較関数
function compare( a, b ){
  var r = 0;
  if( a.start_time_u < b.start_time_u ){
  	r = -1;
  }else if( a.start_time_u > b.start_time_u ){
  	r = 1;
  }
  return ( -1 * r );
}

function getProgram(program){
	program = JSON.parse(program)
	
	//ソートをさせる
	program.sort(function(atime,btime) {
		Atime = atime.start_time_u;
		Btime = btime.start_time_u;
		Atime = new Date( Atime * 1000 );
		Btime = new Date( Btime * 1000 );
		
		var Ahour = ( Atime.getHours()   < 10 ) ? '0' + Atime.getHours()   : Atime.getHours();
		var Amin  = ( Atime.getMinutes() < 10 ) ? '0' + Atime.getMinutes() : Atime.getMinutes();
		
		var Bhour = ( Btime.getHours()   < 10 ) ? '0' + Btime.getHours()   : Btime.getHours();
		var Bmin  = ( Btime.getMinutes() < 10 ) ? '0' + Btime.getMinutes() : Btime.getMinutes();
		
		return Atime > Btime ? 1 : -1;
	});

	var parent = document.getElementById("cont");
	if(document.getElementsByClassName("timelineBox").length == 0){
		timelineBox = createElement("div", timelineBox, "", "timelineBox");
		parent.appendChild(timelineBox);
	}else{
		timelineBox = document.getElementsByClassName("timelineBox");
		for (var i=0;i<timelineBox.length;i++) {
		 timelineBox[i] = ""
		 parent.removeChild(timelineBox[i]);
		}
		timelineBox = createElement("div", timelineBox, "", "timelineBox");
	  parent.appendChild(timelineBox);
	}

	var g_id = 0;
	for(var g in genreList){
		g_id = genreList[g][0];
		var timeLineTable = createElement("div", timeLineTable, "", "timeLineTable");
		var genreName = createElement("h2", genreName, "", "");
		var program_u = createElement("ul", program_u, "", "");
		var program_l = createElement("li", program_l, "", "");
		timelineBox.appendChild(timeLineTable);
		timeLineTable.appendChild(genreName);
		timeLineTable.appendChild(program_u);
		genreName.textContent = genreList[g][1];
		for(i in program){
			if(g_id == program[i].genre){
				if(program[i].delstatus != true){
					var ic = "program" + i;
					program_l = createElement("li", program_l, "", "");
					program_u.appendChild(program_l);

					//スタート時間
					program_l.appendChild(timeLineDate);

					if(program[i].archives == "true"){
						startTime = createElement("p", startTime, "startTime", "startTime typeYes");
					}else{
						startTime = createElement("p", startTime, "startTime", "startTime");
					}
					//time = program[i].start_time.substring(11,16) + "～";
					d = new Date(program[i].start_time_u * 1000);
					hour = ( '0' + d.getHours() ).slice(-2);
			    	min  = ( '0' + d.getMinutes() ).slice(-2);
					sec   = ( '0' + d.getSeconds() ).slice(-2);
					time = hour + ":" + min + "～"
					timeLineDate.appendChild(startTime);
					startTime.textContent = time;

					//良きボタン
					yokiCount = createElement("p", yokiCount, "yokiCount", "yokiCount");
					timeLineDate.appendChild(yokiCount);
					yokiCount.textContent = program[i].like;


					//サムネイル
					timeLineSumb = createElement("div", timeLineSumb, "timeLineSumb", "timeLineSumb");
					program_l.appendChild(timeLineSumb);
					//本番時には書くこと

					timeLineDate = createElement("div", timeLineDate, "timeLineDate", "timeLineDate");
					thumbnail = createElement("img", thumbnail, "thumbnail", "");
					thumLink = document.createElement("a");
					//サムネイルが存在しない時には画像を表示しない
					if(program[i].image.url != null){
						thumLink.href = "/program/detail/" + program[i].id;
						thumbnail.src = program[i].image.url
						timeLineSumb.appendChild(thumLink);
						thumLink.appendChild(thumbnail);
					}

					//チャンネルアイコンと名前
					username = createElement("div", username, "", "userName");
					program_l.appendChild(username);
					c_icon = createElement("img", c_icon, "", "");
					username.appendChild(c_icon);
					c_icon.src = program[i].c_icon
					c_name = createElement("p", c_name, "", "");
					username.appendChild(c_name);
					c_name.textContent = program[i].c_name;
					//番組タイトル　遷移するようにaタグを親にする
					programLink = document.createElement("a");
					timeLineDatail = createElement("div", timeLineDatail, "timeLineDatail" + i, "timeLineDatail");
					program_l.appendChild(programLink);
					programLink.appendChild(timeLineDatail);
					programLink.href = "/program/detail/" + program[i].id;
					timeLineDatail.textContent = program[i].p_title;
					//タグ表記
					timeLineTag = createElement("div", timeLineTag, "timeLineTag", "timeLineTag");
					program_l.appendChild(timeLineTag);
					timeLineTag.textContent = program[i].tag;
				}
			}
		}
	}
	slicktimeLineBox();
}