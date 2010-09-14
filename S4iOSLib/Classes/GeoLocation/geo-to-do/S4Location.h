
{
	NSString									*m_titleStr;
	NSString									*m_addressStr_1;
	NSString									*m_addressStr_2;
	NSString									*m_neighborhoodStr;
	NSString									*m_cityStr;
	NSString									*m_countyStr;
	NSString									*m_stateStr;
	NSString									*m_postalCodeStr;
	NSString									*m_countryStr;
	NSString									*m_countryCodeStr;
	NSString									*m_phoneStr;



	NSString				*m_TotRatingsStr;
	NSString				*m_DistanceStr;
	NSString				*m_SearchUrlStr;
	NSString				*m_MapUrlStr;
	NSString				*m_BizUrlStr;
}

@property (nonatomic, copy) NSString			*m_titleStr;
@property (nonatomic, copy) NSString			*m_addressStr_1;
@property (nonatomic, copy) NSString			*m_addressStr_2;
@property (nonatomic, copy) NSString			*m_neighborhoodStr;
@property (nonatomic, copy) NSString			*m_cityStr;
@property (nonatomic, copy) NSString			*m_countyStr;
@property (nonatomic, copy) NSString			*m_stateStr;
@property (nonatomic, copy) NSString			*m_postalCodeStr;
@property (nonatomic, copy) NSString			*m_countryStr;
@property (nonatomic, copy) NSString			*m_countryCodeStr;
@property (nonatomic, copy) NSString			*m_phoneStr;


@property (nonatomic, copy) NSString	*m_TotRatingsStr;
@property (nonatomic, copy) NSString	*m_DistanceStr;
@property (nonatomic, copy) NSString	*m_SearchUrlStr;
@property (nonatomic, copy) NSString	*m_MapUrlStr;
@property (nonatomic, copy) NSString	*m_BizUrlStr;


- (BOOL)isEquivalent: (S4Location *)otherObject;


- (void)setLatitude: (double)dLatitude;
- (void)setLatitude: (NSString *)latitudeStr;
- (double)latitudeAsDouble;

- (void)setLongitude: (double)dLongitude;
- (void)setLongitude: (NSString *)longitudeStr;
- (double)longitutdeAsDouble;

- (void)setCoordinate: (CLLocationCoordinate2D)newCoordinate;




- (double)avgRatingAsDouble;
- (BOOL)startReverseGeocoding;
- (double)distanceAsDouble;



@end
