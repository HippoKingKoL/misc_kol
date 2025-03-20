// valuable_items.ash
// HippoKing, March 2025

import <pricegun>

boolean use_pricegun_every_time = false; // This will hit pricegun for every single item in your inventory.
boolean use_pricegun_on_valuable_only = true; // This will just use pricegun for items that Mafia's historical price has already told us are valuable.

int valuable_price_per_item = 1000000; // Print items whose individual value is above this.
int valuable_price_total    = 1000000; // Print items of which your total stock is above this.

// Format int as a comma separated decimal
string d(int n) {
   return to_string(n,"%,d");
}
int get_price_every(item it)
{
	if (use_pricegun_every_time) {
		print("Using pricegun for "+it);
		pricegun_result res = pricegun(it);
		if (it.id == res.itemId) {
			return floor(res.value);
		}
	}
	return historical_price(it);
}

int get_price_valuable(item it)
{
	if (use_pricegun_on_valuable_only) {
		print("Using pricegun for "+it);
		pricegun_result res = pricegun(it);
		if (it.id == res.itemId) {
			return floor(res.value);
		}
	}
	return historical_price(it);
}

void main()
{
	record it_val {
		item it;
		int price_per;
		int n;
	};
	
	int[item] add_maps(int[item] m1, int[item] m2)
	{
		int[item] out = m1;
		foreach it,n in m2 {
			if (out contains it) { out[it] += n; }
			else { out[it] = n; }
		}
		return out;
	}
	
	int[item] my_items;
	my_items = add_maps(my_items, get_inventory());
	my_items = add_maps(my_items, get_storage());
	my_items = add_maps(my_items, get_closet ());
	my_items = add_maps(my_items, get_display());
	
	it_val[int] valuable_items;
	
	int size = 0;
	foreach it,n in my_items
	{
		if (!it.tradeable) { continue; }
		int price = get_price_every(it);
		it_val rec;
		rec.it        = it;
		rec.price_per = price;
		rec.n         = n;
		valuable_items[size++] = rec;
	}
	
	sort valuable_items by value.price_per * value.n;
	
	boolean print_red_warning  = false;
	boolean print_blue_warning = false;
	buffer out_html = to_buffer("<table border=\"1\">");
	foreach i,rec in valuable_items
	{
		int total_value = rec.price_per * rec.n;
		if (total_value > valuable_price_total || rec.price_per > valuable_price_per_item)
		{
			int my_price = get_price_valuable(rec.it);
			string color = "";
			if (my_price == 0) {
				color=" style=color:red";
				print_red_warning = true;
				my_price = rec.price_per;
			}
			if (my_price == 2*autosell_price(rec.it) || my_price == 100) { // we do this even if pricegun failed, mall minimum autosell items may not have the volume for PriceGun
				color=" style=color:blue";
				print_blue_warning = true;
			}
			total_value = my_price * rec.n;
			out_html.append(`<tr{color}><td>{rec.it}</td><td>{d(rec.n)} @ {d(my_price)}</td><td>{d(total_value)}</td></tr>`);
		}
	}
	out_html.append("</table>");
	
	print_html(out_html);
	if (print_red_warning ) { print("Red rows had insufficient sales for PriceGun, used Mafia price instead. May be wrong.","red"); }
	if (print_blue_warning) { print("Blue rows are mall minimum, unlikely to sell for this.","blue"); }
	
	return;
}
