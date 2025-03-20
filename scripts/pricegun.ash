// pricegun.ash
// Hits loathers.net pricegun to get the prices of items.
// HippoKing, March 2025

record pricegun_result
{
    float value;
    int volume;
    string date;
    int itemId;
};

// If fails, will return an empty record. Check result.itemId == it.id for success.
pricegun_result pricegun(item it)
{
    string url = "https://pricegun.loathers.net/api/"+it.id;
    string json = visit_url(url);
    string value_pattern  = '"value": (\\d+\\.?\\d?)';
    string volume_pattern = '"volume": (\\d+)';
    string date_pattern   = '"date": "([\\w:\\-\\.]+)"';
    string itemId_pattern = '"itemId": (\\d+)';
    
    boolean failure = false;
    
    string first_match(string pattern, string text)
    {
        matcher m = create_matcher(pattern, text);
        if (m.find()) { return group(m,1); }
        else { failure = true; }
        return "";
    }
    
    string value  = first_match(value_pattern , json);
    string volume = first_match(volume_pattern, json);
    string date   = first_match(date_pattern  , json);
    string itemId = first_match(itemId_pattern, json);
    pricegun_result result;
    if (failure) {
        print("PriceGun failed on "+it+" - got "+json);
    }
    else {
        result.value  = to_float(value);
        result.volume = to_int  (volume);
        result.date   = date;
        result.itemId = to_int(itemId);
    }
    return result;
}

void main(string... raw_input)
{
    if (count(raw_input) == 0 || raw_input[0]=="help") {
        print("pricegun item - returns the price of an item using PriceGun");
        return;
    }
    
    string it_s = raw_input[0];
    item it = to_item(it_s);
    
    if (it == $item[none]) { // if we didn't get a full match do a fuzzy match
        item[int] matches;
        int i = 0;
        foreach this_it in $items[] {
            if (this_it.tradeable && contains_text(to_lower_case(this_it.name),to_lower_case(it_s))) {
                matches[i++] = this_it;
            }
        }
        if (count(matches)==0) {
            print("Input {it_s} matched no items.","red");
            return;
        }
        else if (count(matches)>1) {
            print(`Input {it_s} matched too many tradeable items:\n`,"red");
            foreach i,m in matches {
                print(m,"red");
            }
            return;
        }
    }
    if (it == $item[none]) {
        print(`Failed to convert {it} to item.`,"red");
        return;
    }
    if (!it.tradeable) {
        print(`{it} is not tradeable`,"red");
        return;
    }
    
    pricegun_result result = pricegun(it);
    if (result.itemId != it.id) {
        return;
    }
    
    string out_string = (result.value == 0 ? "- Insufficient sales to give price.":"@ "+to_string(result.value,"%,.0f"));
    print(it+" "+out_string);
    return;
}
    
    
