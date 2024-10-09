import React, { useState, useEffect } from 'react';

const ZipCodeInput = () => {
  const [zipCode, setZipCode] = useState('');
  const [address, setAddress] = useState({ kana: '', kanji: '', romaji: '' });
  const [error, setError] = useState(null);

  const handleZipCodeChange = (e) => {
    setZipCode(e.target.value);
  };

  useEffect(() => {
    if (zipCode.length === 7) {
      fetchAddress(zipCode);
    }
  }, [zipCode]);

  const fetchAddress = (zipCode) => {
    fetch(`https://postcode.teraren.com/postcodes/${zipCode}.json`)
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to fetch address');
        }
        return response.json();
      })
      .then((data) => {
        setAddress({
          kana: `${data.prefecture_kana} ${data.city_kana} ${data.suburb_kana}`,
          kanji: `${data.prefecture} ${data.city} ${data.suburb}`,
          romaji: `${data.prefecture_kana} ${data.city_kana} ${data.suburb_kana}`.replace(/[\u30a1-\u30f6]/g, (match) => String.fromCharCode(match.charCodeAt(0) - 0x60)),
        });
        setError(null);
      })
      .catch((error) => {
        setAddress({ kana: '', kanji: '', romaji: '' });
        setError(error);
      });
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-red-500 p-8 rounded-lg shadow-lg text-white w-80">
        <h2 className="text-2xl font-bold mb-4">Automatic Address Input</h2>
        <label className="block mb-2">
          Zip Code:
          <input
            type="text"
            value={zipCode}
            onChange={handleZipCodeChange}
            placeholder="Enter zip code"
            className="w-full p-2 mt-2 text-black rounded"
          />
        </label>
        {address && (
          <div className="mb-4">
            <div>カナ: {address.kana}</div>
            <div>漢字: {address.kanji}</div>
            <div>ローマ字: {address.romaji}</div>
          </div>
        )}
        {error && <div className="text-red-300">エラー: {error.message}</div>}
      </div>
    </div>
  );
};

export default ZipCodeInput;
