# allow a 2 pixel difference between the values in array ref 1 and array
# ref 2
sub aeq
{
	my ($ar1, $ar2) = @_;
	for (my $i = 0; $i < @$ar1; $i++)
	{
		return unless defined $ar2->[$i];
		return unless abs($ar1->[$i] - $ar2->[$i]) <= 2;
	}
	return 1;
}
