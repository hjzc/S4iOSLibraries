


//============================================================================
//	S4Placemark :: isEquivalent
//============================================================================
- (BOOL)isEquivalent: (S4Placemark *)otherObject
{
	if ((IS_NOT_NULL(otherObject)) && ([otherObject isKindOfClass: [S4Placemark class]]))
	{
		if (([self.m_titleStr isEqualToString: otherObject.m_titleStr]) &&
			([self.m_addressStr_1 isEqualToString: otherObject.m_addressStr_1]) &&
			([self.m_cityStr isEqualToString: otherObject.m_cityStr]) &&
			([self.m_stateStr isEqualToString: otherObject.m_stateStr]))
		{
			return (YES);
		}
	}
	return (NO);
}






//============================================================================
//	S4Placemark :: startReverseGeocoding
//============================================================================
- (BOOL)startReverseGeocoding
{
	BOOL			bResult = NO;

	m_appleRevGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate: m_cl2DCoordinate];
	if (IS_NOT_NULL(m_appleRevGeocoder))
	{
		m_appleRevGeocoder.delegate = self;
		[m_appleRevGeocoder start];
		bResult = YES;
	}
	return (bResult);
}





@end
