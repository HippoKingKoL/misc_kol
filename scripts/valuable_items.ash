// valuable_items.ash
// HippoKing, March 2025

// Format int as a comma separated decimal
string d(int n) {
   return to_string(n,"%,d");
}

void main()
{
	int valuable_price_per_item = 1000000;
	int valuable_price_total    = 1000000;
	
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
		int price = historical_price(it);
		it_val rec;
		rec.it        = it;
		rec.price_per = price;
		rec.n         = n;
		valuable_items[size++] = rec;
	}
	
	
	sort valuable_items by value.price_per * value.n;
	
	buffer out_html = to_buffer("<table border=\"1\">");
	foreach i,rec in valuable_items
	{
		int total_value = rec.price_per * rec.n;
		if (total_value > valuable_price_total || rec.price_per > valuable_price_per_item)
		{
			out_html.append(`<tr><td>{rec.it}</td><td>{d(rec.n)} @ {d(rec.price_per)}</td><td>{d(total_value)}</td></tr>`);
		}
	}
	out_html.append("</table>");
	
	print_html(out_html);
	
	return;
}
