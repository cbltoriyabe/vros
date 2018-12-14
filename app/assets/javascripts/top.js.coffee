	function test(){
		console.log('テスト');
	};

	function test2(){
		gon.watch("program2",interval: 1000, test() );
	};

  function getProgram(days){
    var	days = $('#selectdate').val();
    //var days = '2018-07-30'
    console.log(days);
    $.ajax({
        url: "/top",
        type: "GET",
        data: { days: days
                },
        dataType: "html",
        success: function(data) {
          for (i in gon.program){
            document.getElementById(gon.program[i].id + "_title").innerHTML = gon.program[i].p_title
            document.getElementById(gon.program[i].id + "_about").innerHTML = gon.program[i].about
          }
        },
        error: function(data) {

          console.log("errror");

        }
      });
    }
