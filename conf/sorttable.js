// Used with under license grant from http://kryogenix.org/code/browser/sorttable/
// Credit for this code goes to Stuart Langridge - http://kryogenix.org/contact

addEvent(window, "load", sortables_init);

var SORT_COLUMN_INDEX;

function sortables_init() {
    // Find all tables with class sortable and make them sortable
    if (!document.getElementsByTagName) return;
    tbls = document.getElementsByTagName("table");
    for (ti=0;ti<tbls.length;ti++) {
        thisTbl = tbls[ti];
        if (ts_hasClass(thisTbl, "sortable")) {
            ts_makeSortable(thisTbl);
        }
    }
}

function ts_getHeaderRowIdx(table) {
    if (table.rows && table.rows.length > 0) {
        // Find first table row with class sortheader
        for (var i=0;i<table.rows.length;i++) {
          if (ts_hasClass(table.rows[i], "sortheader")) {
            return i;
          }
        }
        // No row found with class sortheader : assume first's one is the header
        return 0;
    }
    return false;
}


function ts_makeSortable(table) {
    var headerRowIdx = ts_getHeaderRowIdx(table);
    if (headerRowIdx === false) return;
    var headerRow = table.rows[headerRowIdx];
    
    for (var i=0;i<headerRow.cells.length;i++) {
        var cell = headerRow.cells[i];
        var txt = ts_getInnerText(cell);
        cell.innerHTML = '<a href="#" class="sortheader" '+ 
        'onclick="ts_resortTable(this, '+i+');return false;">' + 
        txt+'<span class="sortarrow">&nbsp;&nbsp;&nbsp;</span></a>';
    }
}

function ts_getInnerText(el) {
	if (typeof el == "string") return el;
	if (typeof el == "undefined") { return el };

    // Not needed but it is faster.
    // We have to trim the content as some versions of Chrome append a trailing tab.
    if (el.innerText) return el.innerText.trim();

	var str = "";
	
	var cs = el.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		switch (cs[i].nodeType) {
			case 1: //ELEMENT_NODE
				str += ts_getInnerText(cs[i]);
				break;
			case 3:	//TEXT_NODE
				str += cs[i].nodeValue;
				break;
		}
	}
	return str;
}

function ts_resortTable(lnk,clid) {
    // get the span
    var span;
    for (var ci=0;ci<lnk.childNodes.length;ci++) {
        if (lnk.childNodes[ci].tagName && lnk.childNodes[ci].tagName.toLowerCase() == 'span') span = lnk.childNodes[ci];
    }
    var spantext = ts_getInnerText(span);
    var td = lnk.parentNode;
    SORT_COLUMN_INDEX = clid || td.cellIndex;
    var table = getParent(td,'TABLE');
    
    // Work out a type for the column
    if (table.rows.length <= 1) return;
    var cell = table.rows[1].cells[SORT_COLUMN_INDEX];
    var itm = ts_getInnerText(cell);
    var date_format = cell.dataset.date_format;    // Get date format from data-* attribute

    sortfn = ts_sort_caseinsensitive;
    if (date_format === "0") {
        sortfn = ts_sort_date_0;
    } else if (date_format === "1") {
        sortfn = ts_sort_date_1;
    } else if (itm.match(/^[£$]/)) {
        sortfn = ts_sort_currency;
    } else if (itm.match(/^[\d\.]+$/)) {
        sortfn = ts_sort_numeric;
    }

    var headerRowIdx = ts_getHeaderRowIdx(table);
    var headerRow = new Array();
    var newRows = new Array();
    for (i=0;i<table.rows[headerRowIdx].length;i++) { headerRow[i] = table.rows[0][i]; }
    for (j=headerRowIdx+1;j<table.rows.length;j++) { newRows[j-headerRowIdx-1] = table.rows[j]; }

    newRows.sort(sortfn);

    if (span.getAttribute("sortdir") == 'down') {
        ARROW = '&nbsp;&nbsp;&uarr;';
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        ARROW = '&nbsp;&nbsp;&darr;';
        span.setAttribute('sortdir','down');
    }
    
    // We appendChild rows that already exist to the tbody, so it moves them rather than creating new ones
    // don't do sortbottom rows
    for (i=0;i<newRows.length;i++) { if (!newRows[i].className || (newRows[i].className && (newRows[i].className.indexOf('sortbottom') == -1))) table.tBodies[0].appendChild(newRows[i]);}
    // do sortbottom rows only
    for (i=0;i<newRows.length;i++) { if (newRows[i].className && (newRows[i].className.indexOf('sortbottom') != -1)) table.tBodies[0].appendChild(newRows[i]);}
    
    // Delete any other arrows there may be showing
    var allspans = document.getElementsByTagName("span");
    for (var ci=0;ci<allspans.length;ci++) {
        if (allspans[ci].className == 'sortarrow') {
            if (getParent(allspans[ci],"table") == getParent(lnk,"table")) { // in the same table as us?
                allspans[ci].innerHTML = '&nbsp;&nbsp;&nbsp;';
            }
        }
    }
        
    span.innerHTML = ARROW;
}

function getParent(el, pTagName) {
	if (el == null) return null;
	else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
		return el;
	else
		return getParent(el.parentNode, pTagName);
}

function ts_hasClass(el, className) {
        if ((' '+el.className+' ').indexOf((' '+className+' ')) != -1) {
		return true;
	}
	return false;
}

function getCellText(row) {
    return ts_getInnerText(row.cells[SORT_COLUMN_INDEX]);
}

/**
 * Parse a date string and convert it to a JavaScript Date object.
 * @param {string} str - Date string.
 * @param {number} format - Date format: 0 - "MM/DD HH:MM" or "MM/DD/YY HH:MM", 1 - "DD/MM HH:MM" or "DD/MM/YY HH:MM".
 * @returns {object} JavaScript Date object.
 */
function str2date(str, format) {
    var arr = str.match(/(\d{1,2})\/(\d{1,2})(?:\/(\d{2}))? (\d{2}):(\d{2})/);

    var year = arr[3] ? ara[3] : (new Date()).getFullYear();
    var month = arr[format ? 1 : 2] - 1;
    var day = arr[format ? 2 : 1];
    var hour = arr[4];
    var minute = arr[5];

    return new Date(year, month, day, hour, minute);
}

function ts_sort_date_0(a,b) {
    var aa = getCellText(a);
    var bb = getCellText(b);
    return str2date(aa, 0) - str2date(bb, 0);
}

function ts_sort_date_1(a,b) {
    var aa = getCellText(a);
    var bb = getCellText(b);
    return str2date(aa, 1) - str2date(bb, 1);
}

function ts_sort_currency(a,b) {
    var aa = getCellText(a).replace(/[^0-9.]/g,'');
    var bb = getCellText(b).replace(/[^0-9.]/g,'');
    return parseFloat(aa) - parseFloat(bb);
}

function ts_sort_numeric(a,b) {
    var aa = parseFloat(getCellText(a));
    if (isNaN(aa)) aa = 0;
    var bb = parseFloat(getCellText(b));
    if (isNaN(bb)) bb = 0;
    return aa-bb;
}

function ts_sort_caseinsensitive(a,b) {
    var aa = getCellText(a).toLowerCase();
    var bb = getCellText(b).toLowerCase();
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}

function ts_sort_default(a,b) {
    var aa = getCellText(a);
    var bb = getCellText(b);
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}

function addEvent(elm, evType, fn, useCapture)
// addEvent and removeEvent
// cross-browser event handling for IE5+,  NS6 and Mozilla
// By Scott Andrew
{
  if (elm.addEventListener){
    elm.addEventListener(evType, fn, useCapture);
    return true;
  } else if (elm.attachEvent){
    var r = elm.attachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
}
