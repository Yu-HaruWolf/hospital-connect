// Import the functions you need from the SDKs you need
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.4.0/firebase-app.js';
import { getFirestore,collection, addDoc,getDoc,getDocs,query, where,GeoPoint,doc, updateDoc} from 'https://www.gstatic.com/firebasejs/10.4.0/firebase-firestore.js';
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
	apiKey: "AIzaSyCAXeaS9p1P4gnyywlx4E20zoO6jxjaeWs",
	authDomain: "tcu-rescue.firebaseapp.com",
	projectId: "tcu-rescue",
	storageBucket: "tcu-rescue.appspot.com",
	messagingSenderId: "246901411650",
	appId: "1:246901411650:web:86d48bc20cb31ba88682db"
};
// Initialize Firebase
const app = initializeApp(firebaseConfig); //firebaseにアクセス
const db = getFirestore(app);  //データベースにアクセス
const requestRef = collection(db, "request");

/*データベース*/
const hospitalData = {
	ID : '0000',
	address : 'japana',
	call : '08012345678',
	name : '高須クリニック',
	place: new GeoPoint(35.6895, 139.6917),
	department: {
		0: false,
		1: false,
		2: false,
		3: false,
		4: false,
		5: false,
		6: false,
		7: false,
		8: false,
		9: false,
		10: false,
		11: false
	},
	numOfAccepted : 10
};
/*データベース*/

/*ここから関数*/
/*
関数概要：緯度経度を用いて救急車から目的地の病院までの距離を算出し病院のリストを距離を注目し昇順にソートする関数
引数1：救急車が選択した診療科に当てはまる病院のドキュメントplaces
引数2：現在地origin
戻り値: ソートされたリスト hospitalList 
*/
async function getSortHospitalList(places,origin) {
	const destinations = [];
	let hospitalList = []; // 二重配列 [[病院ドキュメント, その病院と都市大との距離]]
	//救急車の現在地から目的地（病院）の距離を算出し，destinationsにプッシュ
	places.forEach(function(value){
			let d = new google.maps.LatLng(value.place.latitude, value.place.longitude)
			destinations.push(d)
	})

	//現在の救急車の位置から検索し当てはまったすべての病院までの距離をセットにし，hospitalListにプッシュ
	const service = new google.maps.DistanceMatrixService();
	service.getDistanceMatrix({
		origins: [origin],
		destinations: destinations,
		travelMode: 'DRIVING',
	}, (response, status) => {
			if (status === 'OK') {
				for(let i = 0; i<destinations.length; i++){
					const distance = response.rows[0].elements[i].distance.value;
					hospitalList.push([places[i], distance]);//病院のdocと距離をリストにプッシュ
				}
				hospitalList.sort((a, b) => a[1] - b[1]);//hospitalListを距離に注目して昇順ソート
				//console.log(hospitalList);
				return hospitalList;
			} else {
				console.error('Error:', status);
				return ;
			}
	});
}

/*
関数概要：引数の診療科すべて当てはまる病院のリストを取得
引数：診療科のリスト
戻り値：引数のリストすべて満たす病院のリスト
*/
async function getHospitalsAnd(depArray){
	const hospitalRef = collection(db, "hospital");
	let queryAnd = query(hospitalRef, where(depArray[0], "==", true));
	for ( var i = 1; i < depArray.length; i++ ){
		queryAnd = query(queryAnd, where(depArray[i], "==", true))
	};
	const hospitals = [] ;
	const querySnapshot = await getDocs(queryAnd);
	querySnapshot.forEach((doc) => { // 病院の情報を取得 & consoleに表示
			//console.log(doc.id, " => ", doc.data());
			//console.log(doc.data().name)//フィールド取得
			hospitals.push(doc.data());//リストで返す
			//console.log(hospitals[0].place.latitude);
	});
	//console.log(hospitals);
	return hospitals;
}

/*
関数概要：引数の診療科がひとつでも当てはまる病院のリストを取得
引数：診療科のリスト
戻り値：引数のリストがひとつでも満たす病院のリスト
*/
async function getHospitalsOr(depArray){
	const hospitalRef = collection(db, "hospital");
	let hospitalName = {} //空の辞書作成
	for ( var i = 0; i < depArray.length; i++ ){
		var q = query(hospitalRef, where(depArray[i], "==", true));
		const querySnapshot = await getDocs(q);
		querySnapshot.forEach((doc) => {
		hospitalName[doc.data().name] = doc.data() // keyが重複した場合、後に追加したデータが優先される
		});
	};
	//console.log(hospitalName["高須クリニック0"])
	const hospitals = Object.values(hospitalName) // 辞書からvalue(病院data)の一覧を取得
	return hospitals ;
}
/*
関数概要：depertmentドキュメントの日本語か英語の科の名前を取得
引数：ja 文字列
戻り値：対応する言語の科のリスト
*/
async function getDepartment(language){  
	if(language !== "ja" && language != "en"){
		console.error("Invalid language code. Please provide 'ja' for Japanese or 'en' for English.");
		return ;
	}
	const departmentRef = collection(db, "department");
	const depList = []
	const querySnapshot = await getDocs(departmentRef);
	querySnapshot.forEach((doc)=>{
		if(language == "ja"){
			depList.push(doc.data().ja);
		}else if(language == "en"){
			depList.push(doc.data().en);
		}
	});
	return depList;
};

/*
関数概要：受け入れ人数を病院単位で変更
引数1：病院名
引数2：人数
戻り値：なし
*/
async function updatenumOfAccepted(hospitalName,num){
	const hospitalRef = collection(db, "hospital");
	const searchHospital = document.getElementById(hospitalName).value;
	const q = query(hospitalRef, where("name", "==", searchHospital ));
	const querySnapshot = await getDocs(q);
	//console.log(querySnapshot);

	//当てはまる病院の受け入れ人数を更新
	querySnapshot.forEach(async (doc) => { 
		//ドキュメントIDと受け入れ人数を出力
		//console.log(doc.id, " => ", doc.data());
		//console.log(doc.data().numOfAccepted);
		//テキストボックスに入力された文字列を10進数に変換
		const numOfAcceptedIDValue = document.getElementById(num).value;
		const numOfAcceptedIDNumber = parseInt(numOfAcceptedIDValue, 10);

		//ドキュメントIDに対して受け入れ人数を更新
		const hospitalDocRef = doc.ref;
		await updateDoc(hospitalDocRef,{
		numOfAccepted: numOfAcceptedIDNumber
		});
		console.log("update numOfAccepted")
		});
}
/*ここまで関数*/

/*ここからIDに対するアクション*/
//内科ボタンをクリックされると以下の関数が実行される。　リクエストを作成
$("#dep00").on("click",async function() {
	const a =  await addDoc(requestRef,{
			patient : '0',
			ambulance : '0616',
			status : 'progress'
	});
	const recDoc = await a.path;
	console.log(recDoc);
});

//hospitalArrayの情報とすべて当てはまる病院を表示(AND検索)
const hospitalArray = ['department.0', 'department.1','department.2']//仮に与えられたとする
const now = new google.maps.LatLng(35.5988, 139.6506); //仮に救急車の現在地を都市大の位置とする
$("#searchAnd").on("click",async function(){
	const hospitals = await getHospitalsAnd(hospitalArray);//選択されたすべての診療科が対応している病院を取得
	getSortHospitalList(hospitals,now);//現在地から近い順にソート
	console.log(hospitals);
});


	//hospitalArrayの情報とひとつでも当てはまる病院を表示(OR検索)
$("#searchOr").on("click",async function(){
	const hospitals = await getHospitalsOr(hospitalArray);
	getSortHospitalList(hospitals,now);
	console.log(hospitals);
});


//病院を新規に登録
$("#submit").on("click",async function() {
	await addDoc(collection(db,"hospital"),hospitalData)
	.then(() => {
    console.log("Document successfully written!");
	})
	.catch((error) => {
    console.error("Error writing doccument :",error);
	});
});

//病院の受け入れ人数変更
$("#update").on("click",async function(){
	//病院名検索
	updatenumOfAccepted("hospitalName","numOfAcceptedID");
});
/*ここまでIDに対するアクション*/

/*診療科を取得*/
const tmp = await getDepartment("ja");
console.log(tmp);